# newModules/home/desktop/wlogout.nix
{ self, ... }: {
  flake.modules.homeManager.wlogout = { config, ... }: {
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "shutdown";
          action = "sleep 1; systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "reboot";
          action = "sleep 1; systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
        {
          label = "logout";
          action = "sleep 1; loginctl terminate-session $XDG_SESSION_ID";
          text = "Exit";
          keybind = "e";
        }
        {
          label = "suspend";
          action = "sleep 1; systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "lock";
          action = "sleep 1; loginctl lock-session $XDG_SESSION_ID";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "hibernate";
          action = "sleep 1; systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
      ];

      style =
        let
          c = config.lib.stylix.colors;
          fg      = "#${c.base05}";
          fgAlt   = "#${c.base01}";
          bg      = "rgba(12, 12, 12, 0.3)";
          bgHover = "rgba(12, 12, 12, 0.5)";
          bgWin   = "rgba(12, 12, 12, 0.1)";
        in
        ''
          * {
            font-family: "JetBrainsMono NF", FontAwesome, sans-serif;
            background-image: none;
            transition: 20ms;
          }
          window {
            background-color: ${bgWin};
          }
          button {
            color: ${fg};
            font-size: 20px;
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
            border-style: solid;
            background-color: ${bg};
            border: 3px solid ${fg};
            box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2),
                        0 6px 20px 0 rgba(0, 0, 0, 0.19);
          }
          button:focus,
          button:active,
          button:hover {
            color: ${fgAlt};
            background-color: ${bgHover};
            border: 3px solid ${fgAlt};
          }
          #logout {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/logout.png"));
          }
          #suspend {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/suspend.png"));
          }
          #shutdown {
            margin: 10px;
            border-radius: 20px;
            background-image: -gtk-scaled(url("icons/shutdown.png"));
          }
          #reboot {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/reboot.png"));
          }
          #lock {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/lock.png"));
          }
          #hibernate {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/hibernate.png"));
          }
        '';
    };

    home.file.".config/wlogout/icons" = {
      source = ./icons;
      recursive = true;
    };
  };
}