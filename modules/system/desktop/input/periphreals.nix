# Gaming mouse configuration via libratbag/piper.
# Supports button remapping, DPI profiles, and LED configuration
# for gaming mice including the Logitech G502 Hero.
#
# Usage:
#   Add self.nixosModules.gaming-mouse to your host's modules list.
#   Then run `piper` to configure the mouse.
{
  flake.nixosModules.periphreals = { pkgs, ... }: {
    # ratbagd daemon -- communicates with gaming mice
    services.ratbagd.enable = true;

    # shoving this here for now, not really needed since its all disabled
    # TODO: rename this to periphreals or something
    # hardware = {
    #   # Enable flashing QMK-compatible keyboards
    #   keyboard.qmk.enable = false;

    #   # Logitech wireless receiver -- disabled in favour of ratbagd
    #   logitech.wireless.enable = false;
    #   logitech.wireless.enableGraphical = false;
    # };

    environment.systemPackages = with pkgs; [
      piper  # GUI for configuring gaming mice
    ];
  };
}