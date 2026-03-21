# Flake-parts module for Framework laptop LED control.
# Automatically sets the power LED color based on system state:
#   - Red when battery is low (≤15%) and discharging
#   - Off when screen brightness is low (≤20%)
#   - White otherwise
#
# Triggered by udev events on battery and backlight changes,
# so it reacts instantly with no polling overhead.
#
# Usage:
#   Automatically a part of the brick host, via sharing the module.
#
#   Verify it's working after rebuild:
#     udevadm monitor --subsystem-match=backlight    # watch backlight events
#     udevadm monitor --subsystem-match=power_supply # watch battery events
#     sudo ectool led power red                      # manually test LED
_: {
  flake.nixosModules.hostBrick = {
    pkgs,
    ...
  }: let
    led-control = pkgs.writeShellApplication {
      name = "led-control";
      runtimeInputs = with pkgs; [
        fw-ectool
        brightnessctl
      ];
      text = ''
        battery=$(cat /sys/class/power_supply/BAT1/capacity)
        status=$(cat /sys/class/power_supply/BAT1/status)
        brightness=$(brightnessctl get)
        max=$(brightnessctl max)
        brightness_pct=$((brightness * 100 / max))

        # Priority 1: low battery while discharging
        if [ "$battery" -le 15 ] && [ "$status" = "Discharging" ]; then
          ectool led power red
          exit 0
        fi

        # Priority 2: low brightness (night mode)
        if [ "$brightness_pct" -le 20 ]; then
          ectool led power off
          exit 0
        fi

        # Default
        ectool led power white
      '';
    };
  in {
    services.udev.extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Battery", RUN+="${led-control}/bin/led-control"
      SUBSYSTEM=="backlight", RUN+="${led-control}/bin/led-control"
    '';
  };
}