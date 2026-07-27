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
    # Session files registered by programs.niri / programs.hyprland.
    # Both launch their proper session wrappers (niri-session and
    # start-hyprland), so systemd targets and the watchdog are kept.
    sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  in {
    # boot.kernelParams = [ "video=2256x1504" ];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          user = config.host.username;
          # niri is the default (plain Enter); F3 opens the session menu
          # to fall back to Hyprland, and the last choice is remembered
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${sessions} --cmd niri-session";
        };
      };
    };
  };
}
