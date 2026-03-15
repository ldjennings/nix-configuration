# Gaming mouse configuration via libratbag/piper.
# Supports button remapping, DPI profiles, and LED configuration
# for gaming mice including the Logitech G502 Hero.
#
# Usage:
#   Add self.nixosModules.gaming-mouse to your host's modules list.
#   Then run `piper` to configure the mouse.
{
  flake.nixosModules.gamingMouse = { pkgs, ... }: {
    # ratbagd daemon -- communicates with gaming mice
    services.ratbagd.enable = true;

    environment.systemPackages = with pkgs; [
      piper  # GUI for configuring gaming mice
    ];
  };
}