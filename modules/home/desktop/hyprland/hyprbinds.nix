# newModules/home/desktop/hyprland/binds.nix
{ self, ... }: {
  flake.modules.homeManager.hyprland = _: {
    wayland.windowManager.hyprland.settings = {
      "$modifier" = "SUPER";

      bind = [
        # Terminal
        "$modifier, Return, exec, kitty"

        # Launcher, closes if done again
        "$modifier CTRL, Return, exec, pkill rofi || rofi -show drun"

        # Waybar toggle
        "$modifier, semicolon, exec, pkill -SIGUSR1 waybar"

        # Apps
        "$modifier, B, exec, firefox"
        "$modifier, O, exec, obsidian"
        "$modifier, Y, exec, kitty -e yazi"
        "$modifier, M, exec, pavucontrol"
        "$modifier, D, exec, discord"
        "$modifier, C, exec, hyprpicker -a"
        "$modifier, G, exec, gimp"

        # Scratchpad terminal
        "$modifier, T, exec, pypr toggle term"

        # Clipboard
        "$modifier, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # Notifications
        "$modifier SHIFT, N, exec, swaync-client -rs"

        # Screenshot
        "$modifier, S, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$modifier SHIFT, S, exec, grim - | swappy -f -"
        "$modifier ALT, S, exec, grim -g \"$(slurp -o)\" - | swappy -f -"

        # Night light
        ", Print, exec, toggle-light-filter"

        # Brightness
        ", XF86MonBrightnessDown, exec, brightness-gamma down"
        ", XF86MonBrightnessUp, exec, brightness-gamma up"

        # Volume
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        # Media
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        # Open config in VSCode
        ", XF86AudioMedia, exec, code /home/liam/nix-configuration --new-window"

        # Window management
        "$modifier, Q, killactive"
        "$modifier, F, fullscreen"
        "$modifier SHIFT, F, togglefloating"
        "$modifier ALT, F, workspaceopt, allfloat"
        "$modifier SHIFT, C, exit"
        "$modifier, P, pseudo"
        "$modifier SHIFT, I, togglesplit"

        # Focus
        "$modifier, h, movefocus, l"
        "$modifier, l, movefocus, r"
        "$modifier, k, movefocus, u"
        "$modifier, j, movefocus, d"
        "$modifier, left, movefocus, l"
        "$modifier, right, movefocus, r"
        "$modifier, up, movefocus, u"
        "$modifier, down, movefocus, d"

        # Move windows
        "$modifier SHIFT, h, movewindow, l"
        "$modifier SHIFT, l, movewindow, r"
        "$modifier SHIFT, k, movewindow, u"
        "$modifier SHIFT, j, movewindow, d"
        "$modifier SHIFT, left, movewindow, l"
        "$modifier SHIFT, right, movewindow, r"
        "$modifier SHIFT, up, movewindow, u"
        "$modifier SHIFT, down, movewindow, d"

        # Swap windows
        "$modifier ALT, h, swapwindow, l"
        "$modifier ALT, l, swapwindow, r"
        "$modifier ALT, k, swapwindow, u"
        "$modifier ALT, j, swapwindow, d"
        "$modifier ALT, left, swapwindow, l"
        "$modifier ALT, right, swapwindow, r"
        "$modifier ALT, up, swapwindow, u"
        "$modifier ALT, down, swapwindow, d"

        # Workspaces
        "$modifier, 1, workspace, 1"
        "$modifier, 2, workspace, 2"
        "$modifier, 3, workspace, 3"
        "$modifier, 4, workspace, 4"
        "$modifier, 5, workspace, 5"
        "$modifier, 6, workspace, 6"
        "$modifier, 7, workspace, 7"
        "$modifier, 8, workspace, 8"
        "$modifier, 9, workspace, 9"
        "$modifier, 0, workspace, 10"
        "$modifier SHIFT, 1, movetoworkspace, 1"
        "$modifier SHIFT, 2, movetoworkspace, 2"
        "$modifier SHIFT, 3, movetoworkspace, 3"
        "$modifier SHIFT, 4, movetoworkspace, 4"
        "$modifier SHIFT, 5, movetoworkspace, 5"
        "$modifier SHIFT, 6, movetoworkspace, 6"
        "$modifier SHIFT, 7, movetoworkspace, 7"
        "$modifier SHIFT, 8, movetoworkspace, 8"
        "$modifier SHIFT, 9, movetoworkspace, 9"
        "$modifier SHIFT, 0, movetoworkspace, 10"
        "$modifier CONTROL, right, workspace, e+1"
        "$modifier CONTROL, left, workspace, e-1"
        "$modifier SHIFT, SPACE, movetoworkspace, special"
        "$modifier, SPACE, togglespecialworkspace"

        # Cycle windows
        "ALT, Tab, cyclenext"
        "ALT, Tab, bringactivetotop"
      ];

      bindm = [
        "$modifier, mouse:272, movewindow"
        "$modifier, mouse:273, resizewindow"
      ];

      bindle = [
        ", mouse_down, workspace, e+1"
        ", mouse_up, workspace, e-1"
      ];
    };
  };
}