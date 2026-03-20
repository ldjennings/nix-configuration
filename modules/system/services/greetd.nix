# Flake-parts module for greetd login manager with tuigreet.
#
# Usage:
#   Add self.nixosModules.greetd to your host's modules list.
#   Requires host.username to be set in your host module:
#
#   host.username = "liam";
_: {
  flake.nixosModules.greetd = { config, lib, pkgs, ... }: {
    # imports = [ self.nixosModules.hostConfig ];
    # imports = [ "${self}/custom-nix-code/host-config.nix" ];

    services.greetd = {
      enable = true;
      settings.default_session = {
        user = config.host.username;
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd hyprland";
      };
    };
  };
}