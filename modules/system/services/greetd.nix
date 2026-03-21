# Flake-parts module for greetd login manager with tuigreet.
#
# Usage:
#   Add self.nixosModules.greetd to your host's modules list.
#   Requires host.username to be set in your host module:
#
#   host.username = "liam";
_: {
  flake.nixosModules.greetd = {
    config,
    pkgs,
    ...
  }: let
    hyprland-start = pkgs.writeShellScript "hyprland-start" ''
      hyprland > /tmp/hyprland.log 2>&1
      if [ $? -ne 0 ]; then
        echo "Hyprland exited with error. Log:"
        cat /tmp/hyprland.log
        read -p "Press enter to continue..."
      fi
    '';
  in {
    services.greetd = {
      enable = true;
      settings.default_session = {
        user = config.host.username;
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${hyprland-start}";
      };
    };
  };
}