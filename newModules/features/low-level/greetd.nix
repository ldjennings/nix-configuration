# Flake-parts module for greetd login manager with tuigreet.
#
# Usage:
#   Add self.nixosModules.greetd to your host's modules list,
#   then set the login user in your host module:
#
#   greetd-config.loginUser = username;
{ ... }: {
  flake.nixosModules.greetd = { config, lib, pkgs, ... }: {
    options.greetd-config = {
      loginUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The user to log in as.";
        example = "liam";
      };
    };

    config = {
      assertions = [
        {
          assertion = config.greetd-config.loginUser != null;
          message = ''
            greetd-config.loginUser is not set.
            Add the following to your host module
            where nixosModules.greetd is imported:
              greetd-config.loginUser = username;
          '';
        }
      ];

      services.greetd = {
        enable = true;
        settings.default_session = {
          user = lib.mkIf
            (config.greetd-config.loginUser != null)
            config.greetd-config.loginUser;
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        };
      };
    };
  };
}