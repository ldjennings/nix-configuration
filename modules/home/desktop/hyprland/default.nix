# newModules/home/desktop/hyprland/default.nix
# Core Hyprland configuration -- input, layout, decorations, startup.
_: {
  flake.modules.homeManager.hyprland = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      swww               # wallpaper daemon
      grim               # screenshot tool
      slurp              # screen region selector
      wl-clipboard       # Wayland clipboard
      swappy             # screenshot annotation
      ydotool            # input automation
      hyprpolkitagent    # polkit authentication agent
      hyprland-qtutils   # needed for ANR dialogs and banners
    ];

    # Copy wallpapers and face icon into home directory
    home.file = {
      "Pictures/Wallpapers" = {
        source = ../../../../wallpapers;
        recursive = true;
      };
      ".face.icon".source    = ./face.jpg;
      ".config/face.jpg".source = ./face.jpg;
    };

    # Start hyprland-session target which triggers xdg autostart
    systemd.user.targets.hyprland-session.Unit.Wants = [
      "xdg-desktop-autostart.target"
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      systemd = {
        enable = true;
        enableXdgAutostart = true;
        variables = [ "--all" ];
      };
      xwayland.enable = true;

      settings = {
        exec-once = [
          # Clipboard history
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"

          # Import Wayland environment into systemd and dbus
          "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

          # Polkit agent for authentication dialogs
          "systemctl --user start hyprpolkitagent"

          # Wallpaper daemon
          "killall -q swww; sleep .5 && swww-daemon &"
          "sleep 1.5 && swww img ~/Pictures/Wallpapers/astronaut_jellyfish.jpg"

          # Status bar and notifications
          "killall -q waybar; sleep .5 && waybar"
          "killall -q swaync; sleep .5 && swaync"

          # Network applet
          "nm-applet --indicator"

          # Scratchpad daemon
          "pypr &"

          # Open obsidian silently on special workspace
          "[workspace special silent] obsidian"
        ];

        input = {
          kb_layout  = "us";
          kb_variant = "colemak";
          numlock_by_default = true;
          repeat_delay = 300;
          follow_mouse = 1;
          float_switch_override_focus = 0;
          sensitivity = 0;
          touchpad = {
            natural_scroll     = true;
            disable_while_typing = true;
            scroll_factor      = 0.8;
          };
        };

        gestures = {
          workspace_swipe_distance        = 500;
          workspace_swipe_invert          = true;
          workspace_swipe_min_speed_to_force = 30;
          workspace_swipe_cancel_ratio    = 0.5;
          workspace_swipe_create_new      = true;
          workspace_swipe_forever         = true;
        };

        gesture = [ "3, horizontal, workspace" ];

        general = {
          "$modifier"    = "SUPER";
          layout         = "dwindle";
          gaps_in        = 6;
          gaps_out       = 8;
          border_size    = 2;
          resize_on_border = true;
          "col.active_border"   = "rgb(${config.lib.stylix.colors.base0D})";
          "col.inactive_border" = "rgb(${config.lib.stylix.colors.base03})";
        };

        misc = {
          layers_hog_keyboard_focus  = true;
          initial_workspace_tracking = 0;
          mouse_move_enables_dpms    = true;
          key_press_enables_dpms     = false;
          disable_hyprland_logo      = true;
          disable_splash_rendering   = true;
          enable_swallow             = false;
          vfr = true;  # variable frame rate -- saves power
          vrr = 2;     # variable refresh rate -- set to 0 if screen flickers
          enable_anr_dialog          = true;
          anr_missed_pings           = 20;
        };

        dwindle = {
          pseudotile     = true;
          preserve_split = true;
          force_split    = 2;
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled          = false;
            size             = 5;
            passes           = 3;
            ignore_opacity   = false;
            new_optimizations = true;
          };
          shadow = {
            enabled     = true;
            range       = 4;
            render_power = 3;
            color       = "rgba(1a1a1aee)";
          };
        };

        ecosystem = {
          no_donation_nag  = true;
          no_update_news   = false;
        };

        cursor = {
          sync_gsettings_theme  = true;
          no_hardware_cursors   = 2;
          enable_hyprcursor     = false;
          warp_on_change_workspace = 2;
          no_warps              = true;
        };

        render = {
          direct_scanout        = 0;
          new_render_scheduling = true;
        };

        master = {
          new_status = "master";
          new_on_top = 1;
          mfact      = 0.5;
        };
      };

      # Monitor configuration -- brick-specific
      # eDP-1 is the built-in Framework display at native resolution with fractional scaling
      # DP-7 is an external monitor at auto settings
      extraConfig = ''
        monitor = , preferred, auto, auto
        monitor = eDP-1, 2256x1504@59.99900, auto, 1.175
        monitor = DP-7, 1920x1080@60.00000, auto, auto
      '';
    };
  };
}