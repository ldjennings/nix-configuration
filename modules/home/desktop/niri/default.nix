# newModules/home/desktop/niri/default.nix
{inputs, ...}: {
  flake.modules.homeManager.niri = {
    hostConfig,
    pkgs,
    config,
    ...
  }: {
    imports = [inputs.niri.homeModules.niri];

    # playerctl backs the XF86Audio{Play,Next,Prev} binds below. It wasn't
    # installed, so the media keys silently did nothing (wpctl and
    # brightnessctl come from pipewire / sys-utils respectively).
    home.packages = [pkgs.playerctl];

    programs.niri = {
      enable = true;
      # nixpkgs build (binary-cached) -- niri-flake only supplies the
      # settings DSL below, not the package
      package = pkgs.niri;

      settings = {
        # --- General ---
        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/niri-%Y-%m-%d-%H-%M-%S.png";

        # --- Outputs ---
        # Framework built-in display, matching the Hyprland monitor config;
        # external monitors fall back to niri's automatic settings
        outputs."eDP-1" = {
          mode = {
            width = 2256;
            height = 1504;
            refresh = 59.999;
          };
          scale = 1.175;
        };

        # --- Startup ---
        spawn-at-startup = [
          # Noctalia shell: bar, notifications, launcher, lock screen,
          # wallpaper, OSDs. Spawned here rather than as a systemd unit so
          # it doesn't also start inside Hyprland sessions during migration.
          {command = ["noctalia"];}
          # polkit authentication agent -- draws the password prompt when
          # apps request privileged actions (udisks2 mounts, fwupd, libvirt)
          {command = ["${pkgs.soteria}/bin/soteria"];}
          # network tray applet
          {command = ["nm-applet" "--indicator"];}
          # Notes app -- the window rule above sends it to the notes
          # workspace, so Super+Space always has something to toggle to.
          {command = ["obsidian"];}
        ];

        # --- Input ---
        input = {
          keyboard = {
            xkb = {
              inherit (hostConfig.keyboard) layout;
              inherit (hostConfig.keyboard) variant;
              inherit (hostConfig.keyboard) options;
            };
            repeat-delay = 300;
            repeat-rate = 50;
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
            dwt = true;
          };
          # disable-power-key-handling = true;
          mouse.natural-scroll = false;
          warp-mouse-to-focus.enable = false;
          workspace-auto-back-and-forth = true;
        };

        # --- Appearance ---
        layout = {
          gaps = 8;
          center-focused-column = "never";
          preset-column-widths = [
            {proportion = 0.33;}
            {proportion = 0.5;}
            {proportion = 0.67;}
          ];
          default-column-width = {
            proportion = 0.5;
          };
          border = {
            enable = true;
            width = 1;
            active.color = "#${config.lib.stylix.colors.base0D}";
            inactive.color = "#${config.lib.stylix.colors.base03}";
          };
        };

        workspaces = {
          "notes" = {};
          "chat" = {};
          "scratch_tty" = {};
        };

        # --- Window rules ---
        window-rules = [
          # Keep Obsidian (the notes app) on the notes workspace so
          # Super+Space always toggles to it -- replaces Hyprland's
          # "[workspace special silent] obsidian".
          {
            matches = [{app-id = "^obsidian$";}];
            open-on-workspace = "notes";
          }
          # Slight rounded corners on every window. clip-to-geometry makes the
          # window surface itself follow the radius, not just the border.
          {
            geometry-corner-radius = {
              top-left = 8.0;
              top-right = 8.0;
              bottom-right = 8.0;
              bottom-left = 8.0;
            };
            clip-to-geometry = true;
          }
        ];

        # --- Animations ---
        animations.enable = true;

        # --- Binds ---
        binds = let
          mod = "Super";
          # niri has no Hyprland-style scratchpad / special workspace. This
          # script reproduces the "toggle special workspace" feel for the
          # notes workspace: jump to it, and on a second press jump back to
          # whichever workspace you came from (focus-workspace-previous).
          notesToggle = pkgs.writeShellScript "niri-notes-toggle" ''
            focused=$(${pkgs.niri}/bin/niri msg --json workspaces \
              | ${pkgs.jq}/bin/jq -r '.[] | select(.is_focused) | .name')
            if [ "$focused" = "notes" ]; then
              ${pkgs.niri}/bin/niri msg action focus-workspace-previous
            else
              ${pkgs.niri}/bin/niri msg action focus-workspace notes
            fi
          '';
          # Print toggles noctalia's night light (the compositor tint, applied
          # in-process via wlr-gamma-control -- there is no external gamma
          # process). `led-control toggle` owns the on/off marker and re-renders
          # the Framework LED immediately; see power-led-control.nix. Both are
          # brick-only, so the "|| true" keeps this harmless elsewhere.
          noctalia = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia";
          nightlightToggle = pkgs.writeShellScript "niri-nightlight-toggle" ''
            ${noctalia} msg nightlight-force-toggle
            /run/current-system/sw/bin/led-control toggle || true
          '';
        in {
          # Terminal
          "${mod}+Return".action.spawn = "kitty";

          # Browser
          "${mod}+B".action.spawn = "firefox";

          # Editor
          "${mod}+C".action.spawn = [
            "code"
            "--new-window"
          ];

          # Noctalia launcher: apps, calculator, /emo, /wall, /session, /win
          "${mod}+Control+Return".action.spawn = [
            "noctalia"
            "msg"
            "panel-toggle"
            "launcher"
          ];

          # Noctalia clipboard history
          "${mod}+V".action.spawn = [
            "noctalia"
            "msg"
            "panel-toggle"
            "clipboard"
          ];

          # Noctalia control center
          "${mod}+Escape".action.spawn = [
            "noctalia"
            "msg"
            "panel-toggle"
            "control-center"
          ];

          # rofi kept as fallback launcher during migration
          "${mod}+D".action.spawn = [
            "rofi"
            "-show"
            "drun"
          ];

          # File manager
          "${mod}+Y".action.spawn = [
            "kitty"
            "-e"
            "yazi"
          ];

          # Screenshot
          "${mod}+S".action.screenshot = {
            show-pointer = false;
          };
          "${mod}+Shift+S".action.screenshot-screen = {
            show-pointer = false;
          };
          "${mod}+Alt+S".action.screenshot-window = {};

          # Night light -- toggle noctalia's screen tint (mirrors the old
          # Hyprland ", Print, exec, toggle-light-filter" bind). The wrapper
          # also records the state for the Framework LED script.
          "Print".action.spawn = "${nightlightToggle}";

          # Volume, media and brightness keys.
          #
          # allow-when-locked = true is what lets these fire while the
          # noctalia lock screen is up. niri uses the ext-session-lock
          # protocol and by default inhibits every spawn bind while locked so
          # nobody at a locked screen can run commands. These hardware keys are
          # safe to whitelist -- e.g. brighten the panel when it's suddenly
          # sunny, or mute audio, all without typing the password.

          # Volume
          "XF86AudioRaiseVolume" = {
            action.spawn = [
              "wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%+"
            ];
            allow-when-locked = true;
          };
          "XF86AudioLowerVolume" = {
            action.spawn = [
              "wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%-"
            ];
            allow-when-locked = true;
          };
          "XF86AudioMute" = {
            action.spawn = [
              "wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SINK@"
              "toggle"
            ];
            allow-when-locked = true;
          };

          # Media
          "XF86AudioPlay" = {
            action.spawn = [
              "playerctl"
              "play-pause"
            ];
            allow-when-locked = true;
          };
          # Next/Prev seek within the current track by 10s; hold Shift to
          # skip to the next/previous track instead. playerctl's "position
          # N+/N-" is a relative seek in seconds.
          "XF86AudioNext" = {
            action.spawn = [
              "playerctl"
              "position"
              "10+"
            ];
            allow-when-locked = true;
          };
          "XF86AudioPrev" = {
            action.spawn = [
              "playerctl"
              "position"
              "10-"
            ];
            allow-when-locked = true;
          };
          "Shift+XF86AudioNext" = {
            action.spawn = [
              "playerctl"
              "next"
            ];
            allow-when-locked = true;
          };
          "Shift+XF86AudioPrev" = {
            action.spawn = [
              "playerctl"
              "previous"
            ];
            allow-when-locked = true;
          };

          # Brightness
          "XF86MonBrightnessUp" = {
            action.spawn = [
              "brightnessctl"
              #"--exponent=${BRIGHTNESS_EXPONENT}"
              "--exponent=2.2"
              "set"
              "5%+"
            ];
            allow-when-locked = true;
          };
          "XF86MonBrightnessDown" = {
            action.spawn = [
              "brightnessctl"
              "--exponent=2.2"
              "set"
              "5%-"
            ];
            allow-when-locked = true;
          };

          # Focus movement
          # "${mod}+h".action.focus-column-left = { };
          # "${mod}+l".action.focus-column-right = { };
          # "${mod}+k".action.focus-window-up = { };
          # "${mod}+j".action.focus-window-down = { };
          "${mod}+Left".action.focus-column-left = {};
          "${mod}+Right".action.focus-column-right = {};
          "${mod}+Up".action.focus-window-up = {};
          "${mod}+Down".action.focus-window-down = {};

          # Move windows
          "${mod}+Shift+h".action.move-column-left = {};
          "${mod}+Shift+l".action.move-column-right = {};
          "${mod}+Shift+k".action.move-window-up = {};
          "${mod}+Shift+j".action.move-window-down = {};
          "${mod}+Shift+Left".action.move-column-left = {};
          "${mod}+Shift+Right".action.move-column-right = {};
          "${mod}+Shift+Up".action.move-window-up = {};
          "${mod}+Shift+Down".action.move-window-down = {};

          # Column width
          "${mod}+minus".action.set-column-width = "-10%";
          "${mod}+equal".action.set-column-width = "+10%";

          # Window height
          "${mod}+Shift+minus".action.set-window-height = "-10%";
          "${mod}+Shift+equal".action.set-window-height = "+10%";

          # Fullscreen
          "${mod}+F".action.fullscreen-window = {};
          "${mod}+Shift+F".action.maximize-column = {};

          # Workspaces
          "${mod}+1".action.focus-workspace = 1;
          "${mod}+2".action.focus-workspace = 2;
          "${mod}+3".action.focus-workspace = 3;
          "${mod}+4".action.focus-workspace = 4;
          "${mod}+5".action.focus-workspace = 5;
          "${mod}+Shift+1".action.move-column-to-workspace = 1;
          "${mod}+Shift+2".action.move-column-to-workspace = 2;
          "${mod}+Shift+3".action.move-column-to-workspace = 3;
          "${mod}+Shift+4".action.move-column-to-workspace = 4;
          "${mod}+Shift+5".action.move-column-to-workspace = 5;
          "${mod}+Control+Right".action.focus-workspace-down = {};
          "${mod}+Control+Left".action.focus-workspace-up = {};

          # Notes "scratchpad": Super+Space toggles the notes workspace;
          # Super+Shift+Space sends the focused window there (mirrors the old
          # Hyprland togglespecialworkspace / movetoworkspace-special binds).
          "${mod}+Space".action.spawn = "${notesToggle}";
          "${mod}+Shift+Space".action.move-window-to-workspace = [
            {focus = true;}
            "notes"
          ];
          "${mod}+K".action.move-window-to-workspace = [
            {focus = false;}
            "chat"
          ];

          # Close window
          "${mod}+Q".action.close-window = {};

          # Exit
          "${mod}+Shift+C".action.quit = {};

          # Column management
          "${mod}+I".action.consume-window-into-column = {};
          "${mod}+O".action.expel-window-from-column = {};
        };
      };
    };
  };
}
