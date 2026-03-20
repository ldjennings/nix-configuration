# newModules/home/desktop/niri/default.nix
{inputs, ...}: {
  flake.modules.homeManager.niri = {
    hostConfig,
    pkgs,
    config,
    ...
  }: {
    imports = [inputs.niri.homeModules.niri];

    programs.niri = {
      enable = true;
      package = pkgs.niri-stable;

      settings = {
        # --- General ---
        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/niri-%Y-%m-%d-%H-%M-%S.png";

        # --- Input ---
        input = {
          keyboard = {
            xkb = {
              layout = hostConfig.keyboard.layout;
              variant = hostConfig.keyboard.variant;
              options = hostConfig.keyboard.options;
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

        # --- Animations ---
        animations.enable = true;

        # --- Binds ---
        binds = let
          mod = "Super";
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

          # App launcher
          "${mod}+Control+Return".action.spawn = [
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

          # Volume
          "XF86AudioRaiseVolume".action.spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "5%+"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "5%-"
          ];
          "XF86AudioMute".action.spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];

          # Media
          "XF86AudioPlay".action.spawn = [
            "playerctl"
            "play-pause"
          ];
          "XF86AudioNext".action.spawn = [
            "playerctl"
            "next"
          ];
          "XF86AudioPrev".action.spawn = [
            "playerctl"
            "previous"
          ];

          # Brightness
          "XF86MonBrightnessUp".action.spawn = [
            "brightnessctl"
            #"--exponent=${BRIGHTNESS_EXPONENT}"
            "--exponent=2.2"
            "set"
            "5%+"
          ];
          "XF86MonBrightnessDown".action.spawn = [
            "brightnessctl"
            "--exponent=2.2"
            "set"
            "5%-"
          ];

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

          "${mod}+Space".action.move-window-to-workspace = [
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
