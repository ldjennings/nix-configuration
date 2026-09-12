# Flake-parts module for Framework laptop LED control.
# Automatically sets the power LED color based on system state, in order:
#   - Red when battery is low (≤15%) and discharging
#   - Off when screen brightness is low (≤20%) -- wins over the night light
#   - Amber when the night light is on
#   - White otherwise
#
# Triggered by udev events on battery and backlight changes, and called
# directly by the niri "Print" keybind after it toggles the night light, so
# it reacts instantly with no polling overhead.
#
# On suspend/hibernate the LED is forced off and re-rendered on resume (via
# powerManagement.powerDownCommands/resumeCommands below). Closing the lid
# triggers
# suspend-then-hibernate (services/power-saving.nix), so this is what turns
# the LED off when the lid is shut -- once we pin a colour with `ectool`, the
# EC holds it through sleep, so we have to explicitly clear it.
#
# The LED is driven through `sudo ectool`: EC access needs root, and the
# exact colours (red / white / amber / off) are whitelisted NOPASSWD for the
# user in core/security.nix. That lets the same script work both as root
# (udev) and as the user (the keybind).
#
# Night light: niri has no external gamma process (noctalia applies the tint
# in-process via wlr-gamma-control), so this script keeps an on/off marker in
# /run/nightlight-state. `led-control toggle` (bound to Print in niri) flips
# the marker and re-renders; argument-less runs (udev) just read it. See the
# "Print" bind in modules/home/desktop/niri/default.nix.
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
    config,
    ...
  }: let
    # Shared with the niri "Print" keybind; kept on tmpfs so it resets to
    # "off" every boot.
    nightlightState = "/run/nightlight-state";
    led-control = pkgs.writeShellApplication {
      name = "led-control";
      runtimeInputs = with pkgs; [
        brightnessctl
      ];
      text = ''
        # EC access needs root; the niri keybind runs this as the user, so go
        # through the NOPASSWD `ectool led power ...` rule from core/security.nix.
        ectool() { /run/wrappers/bin/sudo /run/current-system/sw/bin/ectool "$@"; }

        # `led-control toggle` flips the night-light marker (bound to Print in
        # niri); with no argument we just re-render for the current state.
        if [ "''${1:-}" = "toggle" ]; then
          if [ "$(cat ${nightlightState} 2>/dev/null || echo off)" = "on" ]; then
            echo off > ${nightlightState}
          else
            echo on > ${nightlightState}
          fi
        fi

        battery=$(cat /sys/class/power_supply/BAT1/capacity)
        status=$(cat /sys/class/power_supply/BAT1/status)
        brightness=$(brightnessctl get)
        max=$(brightnessctl max)
        brightness_pct=$((brightness * 100 / max))
        # Missing file (e.g. first boot before tmpfiles runs) counts as off.
        nightlight=$(cat ${nightlightState} 2>/dev/null || echo off)

        # Priority 1: low battery while discharging
        if [ "$battery" -le 15 ] && [ "$status" = "Discharging" ]; then
          ectool led power red
          exit 0
        fi

        # Priority 2: low brightness -- off wins over the night-light tint
        if [ "$brightness_pct" -le 20 ]; then
          ectool led power off
          exit 0
        fi

        # Priority 3: night light on -> amber tint
        if [ "$nightlight" = "on" ]; then
          ectool led power amber
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

    # Put led-control on PATH so the niri keybind can call it directly.
    environment.systemPackages = [led-control];

    # Night-light state file owned by the primary user so the (unprivileged)
    # niri keybind can write it. On tmpfs, so it resets to "off" each boot.
    systemd.tmpfiles.rules = [
      "f ${nightlightState} 0644 ${config.host.username} users - off"
    ];

    # Force the LED off while asleep, restore it on resume. This hooks NixOS's
    # sleep-actions unit, which fires on sleep.target -- pulled in by both
    # suspend and hibernate -- with the correct StopWhenUnneeded semantics
    # (powerDownCommands run before sleep, resumeCommands on resume). Root
    # context, so ectool is called directly; the re-render just re-runs
    # led-control for the current battery/brightness/night-light state.
    #
    # Earlier attempt (don't reintroduce): a hand-rolled oneshot with
    # WantedBy=sleep.target but no StopWhenUnneeded. WantedBy only *starts* a
    # unit, so the RemainAfterExit oneshot went active on the first suspend and
    # never stopped -- subsequent suspends didn't re-run the off command, and
    # the resume re-render fired late. The sleep-actions wrapper has
    # StopWhenUnneeded=true, so it re-arms on every cycle.
    #
    # Known hardware flakiness (not a bug here): the Framework occasionally
    # drops the lid-close event (ACPI/SW_LID), most often right after a resume
    # or on a quick close. When that happens logind never logs "Lid closed", so
    # no suspend, so the LED stays on. Verified via journalctl that whenever the
    # event *is* delivered the whole chain works -- single suspend/resume and
    # back-to-back suspend/resume/suspend both go off-then-restore correctly,
    # while locked or unlocked. So an occasional LED-stayed-on after closing the
    # lid is missed hardware events, not this module.
    powerManagement.powerDownCommands = "/run/current-system/sw/bin/ectool led power off";
    powerManagement.resumeCommands = "${led-control}/bin/led-control";
  };
}
