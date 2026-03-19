# newModules/home/desktop/hyprland/waybar.nix
{ self, ... }:
{
  flake.modules.homeManager.hyprland =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.waybar = {
        enable = true;
        package = pkgs.waybar;
        settings =
          let
            # Icon size -- adjust this to scale all icons uniformly
            iconSize = "xx-large"; # small | medium | large | x-large
            icon = i: "<span size='${iconSize}' rise='-5000'>${i}</span>";
            smaller = i: "<span size='x-large'>${i}</span>";
            # icon = i: "<big><big>${i}</big></big>";
          in
          [
            {
              layer = "top";
              position = "top";

              modules-center = [ "hyprland/workspaces" ];
              modules-left = [
                "custom/startmenu"
                "hyprland/window"
                "pulseaudio"
                "cpu"
                "memory"
                "disk"
                # "idle_inhibitor"
              ];
              modules-right = [
                "custom/notification"
                "custom/exit"
                "battery"
                "tray"
                "clock"
              ];

              "hyprland/workspaces" = {
                format = "{name}";
                format-icons = {
                  default = " ";
                  active = " ";
                  urgent = " ";
                };
                on-scroll-up = "hyprctl dispatch workspace e+1";
                on-scroll-down = "hyprctl dispatch workspace e-1";
              };

              "hyprland/window" = {
                max-length = 15;
                separate-outputs = false;
                rewrite = {
                  "" = " ... ";
                };
              };

              "clock" = {
                format = "${icon "󰥔"} {:L%I:%M %p}";
                tooltip = true;
                tooltip-format = "<big>{:%A %B %d, %Y }</big>\n<tt><small>{calendar}</small></tt>";
              };

              "memory" = {
                interval = 5;
                format = "${icon ""} {}%";
                tooltip = true;
              };

              "cpu" = {
                interval = 5;
                format = "${icon ""} {usage:2}%";
                tooltip = true;
              };

              "disk" = {
                interval = 6;
                format = "${icon "󰆓"} {free}";
                tooltip = true;
              };

              "network" = {
                format-icons = [
                  "󰤯"
                  "󰤟"
                  "󰤢"
                  "󰤥"
                  "󰤨"
                ];
                format-ethernet = "${icon "󰈀"} {bandwidthDownOctets}";
                format-wifi = "${icon "{icon}"} {signalStrength}%";
                format-disconnected = icon "󰤮";
                tooltip = false;
              };

              "tray" = {
                spacing = 12;
              };

              "pulseaudio" = {
                format = "${icon "{icon}"} {volume}% {format_source}";
                format-bluetooth = "{volume}% ${icon "{icon}"} {format_source}";
                format-bluetooth-muted = "${icon "󰝟"} ${icon "{icon}"} {format_source}";
                format-muted = "${icon "󰝟"}  {format_source}";
                format-source = "${icon ""} {volume}%";
                format-source-muted = icon "";
                format-icons = {
                  headphone = "";
                  hands-free = "";
                  headset = "";
                  phone = "";
                  portable = "";
                  car = "";
                  default = [
                    ""
                    ""
                    ""
                  ];
                };
                on-click = "sleep 0.1 && pavucontrol";
              };

              "custom/exit" = {
                tooltip = false;
                format = smaller "⏻";
                on-click = "sleep 0.1 && wlogout";
              };

              "custom/startmenu" = {
                tooltip = false;
                format = icon "󱄅";
                on-click = "sleep 0.1 && rofi -show drun";
              };

              # "idle_inhibitor" = {
              #   format = "{icon}";
              #   format-icons = {
              #     activated = "";
              #     deactivated = "";
              #   };
              #   tooltip = "true";
              # };

              "custom/notification" = {
                tooltip = false;
                format = "${icon "{icon}"} {text}";
                # format-icons = {
                #   notification = "<span foreground='red'><sup></sup></span>";
                #   none = "";
                #   dnd-notification = "<span foreground='red'><sup></sup></span>";
                #   dnd-none = "";
                #   inhibited-notification = "<span foreground='red'><sup></sup></span>";
                #   inhibited-none = "";
                #   dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
                #   dnd-inhibited-none = "";
                # };
                format-icons = {
                  notification = "<span foreground='red'><sup></sup></span>";
                  none = "";
                  dnd-notification = "<span foreground='red'><sup></sup></span>";
                  dnd-none = "";
                  inhibited-notification = "<span foreground='red'><sup></sup></span>";
                  inhibited-none = "";
                  dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
                  dnd-inhibited-none = "";
                };
                return-type = "json";
                exec-if = "which swaync-client";
                exec = "swaync-client -swb";
                on-click = "sleep 0.1 && swaync-client -t";
                # escape = true;
              };

              "battery" = {
                states = {
                  warning = 30;
                  critical = 15;
                };
                format = "{icon} {capacity}%";
                format-charging = "󰂄 {capacity}%";
                format-plugged = "󱘖 {capacity}%";
                format-icons = [
                  "󰁺"
                  "󰁻"
                  "󰁼"
                  "󰁽"
                  "󰁾"
                  "󰁿"
                  "󰂀"
                  "󰂁"
                  "󰂂"
                  "󰁹"
                ];
                on-click = "";
                tooltip = false;
              };
            }
          ];

        style =
          let
            c = config.lib.stylix.colors;
            betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";

            # Theme variables
            bg = "#${c.base00}";
            fg = "#${c.base06}";
            fgAlt = "#${c.base05}";
            accent = "#${c.base0D}";
          in
          ''
            * {
              font-family: JetBrainsMono Nerd Font Mono;
              font-size: 18px;
              border-radius: 0px;
              border: none;
              min-height: 0px;
            }
            window#waybar {
              background: rgba(0,0,0,0);
            }
            #workspaces {
              color: ${fg};
              background: ${bg};
              margin: 4px 4px;
              padding: 5px 5px;
              border-radius: 16px;
            }
            #workspaces button {
              font-weight: bold;
              padding: 0px 5px;
              margin: 0px 3px;
              border-radius: 16px;
              color: ${fg};
              background: ${bg};
              opacity: 0.5;
              transition: ${betterTransition};
            }
            #workspaces button.active {
              font-weight: bold;
              padding: 0px 5px;
              margin: 0px 3px;
              border-radius: 16px;
              color: ${bg};
              background: ${fg};
              transition: ${betterTransition};
              opacity: 1.0;
              min-width: 40px;
            }
            #workspaces button:hover {
              font-weight: bold;
              border-radius: 16px;
              color: ${bg};
              background: ${fg};
              opacity: 0.8;
              transition: ${betterTransition};
            }
            tooltip {
              background: ${bg};
              border: 1px solid ${fg};
              border-radius: 12px;
            }
            tooltip label {
              color: ${fg};
            }
            #window, #pulseaudio, #cpu, #memory, #disk, #idle_inhibitor {
              font-weight: bold;
              margin: 4px 0px;
              margin-left: 7px;
              padding: 0px 18px;
              background: ${bg};
              color: ${fg};
              border-radius: 8px 8px 8px 8px;
            }
            #idle_inhibitor {
              font-size: 28px;
            }
            #custom-startmenu {
              color: ${bg};
              background: ${fg};
              font-size: 22px;
              margin: 0px;
              padding: 0px 5px 0px 5px;
              border-radius: 16px 16px 16px 16px;
            }
            #network, #battery, #custom-notification, #tray, #custom-exit {
              font-size: 20px;
              background: ${bg};
              color: ${fg};
              margin: 4px 0px;
              margin-right: 7px;
              border-radius: 8px 8px 8px 8px;
              padding: 0px 18px;
            }
            #clock {
              font-weight: bold;
              font-size: 16px;
              color: ${fg};
              background: ${bg};
              margin: 0px;
              padding: 0px 5px 0px 5px;
              border-radius: 16px 16px 16px 16px;
            }
          '';
      };
    };
}
