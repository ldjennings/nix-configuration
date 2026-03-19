# newModules/home/desktop/rofi.nix
{ self, ... }:
{
  flake.modules.homeManager.rofi =
    { pkgs, config, ... }:
    {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi;
        plugins = with pkgs; [
          (rofi-calc.override { rofi-unwrapped = rofi-unwrapped; })
        ];
        extraConfig = {
          modi = "drun,calc,filebrowser,window,run";
          show-icons = true;
          icon-theme = "kora";
          font = "Fira Sans 11";
          drun-display-format = "{name}";
          display-drun = "";
          display-run = "";
          display-filebrowser = "";
          display-window = "🗔";
          window-format = "{w}\t-\t{c}\t-\t{t}";
          hover-select = false;
          me-select-entry = "";
          me-accept-entry = "MousePrimary";
        };
        theme =
          let
            inherit (config.lib.formats.rasi) mkLiteral;
            c = config.lib.stylix.colors;
            wallpaper = config.stylix.image;
            TRANSPARENT = mkLiteral "transparent";
          in
          {
            "*" = {
              bg = mkLiteral "rgba(0,0,1,0.5)";
              bg-alt = mkLiteral "#${c.base02}";
              foreground = mkLiteral "#${c.base0A}";
              selected = mkLiteral "#${c.base04}";
              active = mkLiteral "#${c.base04}";
              text-selected = mkLiteral "#${c.base0F}";
              text-color = mkLiteral "#${c.base06}";
              border-color = mkLiteral "#${c.base01}";
              urgent = mkLiteral "#${c.base0E}";
            };
            "window" = {
              height = mkLiteral "35em";
              width = mkLiteral "56em";
              transparency = "real";
              fullscreen = false;
              enabled = true;
              cursor = "default";
              spacing = mkLiteral "0em";
              padding = mkLiteral "0em";
              border = mkLiteral "7px";
              border-color = mkLiteral "@border-color";
              border-radius = mkLiteral "2em";
              background-color = mkLiteral "@bg";
            };
            "mainbox" = {
              enabled = true;
              spacing = mkLiteral "0em";
              padding = mkLiteral "0em";
              orientation = mkLiteral "vertical";
              children = map mkLiteral [
                "inputbar"
                "message"
                "listbox"
              ];
              background-color = TRANSPARENT;
              background-image = mkLiteral ''url("${wallpaper}", height)'';
            };
            "inputbar" = {
              enabled = true;
              spacing = mkLiteral "0em";
              padding = mkLiteral "5em";
              children = map mkLiteral [
                "textbox-prompt-colon"
                "entry"
              ];
              background-color = mkLiteral "transparent";
            };
            "textbox-prompt-colon" = {
              enabled = true;
              expand = false;
              str = " →";
              padding = mkLiteral "1em 0.2em 0em 0em";
              text-color = mkLiteral "@foreground";
              background-color = mkLiteral "@bg";
            };
            "entry" = {
              enabled = true;
              border-radius = mkLiteral "0em 2em 2em 0em";
              spacing = mkLiteral "0em";
              padding = mkLiteral "1em";
              background-color = mkLiteral "@bg";
              text-color = mkLiteral "@foreground";
              cursor = mkLiteral "text";
              placeholder = "Search";
              placeholder-color = mkLiteral "inherit";
            };
            "listbox" = {
              padding = mkLiteral "0em";
              spacing = mkLiteral "0em";
              orientation = mkLiteral "horizontal";
              children = map mkLiteral [
                "listview"
                "mode-switcher"
              ];
              background-color = mkLiteral "@bg";
            };
            "listview" = {
              enabled = true;
              columns = 2;
              lines = 4;
              cycle = true;
              dynamic = true;
              scrollbar = false;
              layout = mkLiteral "vertical";
              reverse = false;
              fixed-height = true;
              fixed-columns = true;
              padding = mkLiteral "1.5em";
              spacing = mkLiteral "0.5em";
              background-color = mkLiteral "transparent";
              text-color = mkLiteral "@foreground";
              cursor = "default";
            };
            "mode-switcher" = {
              enabled = true;
              orientation = mkLiteral "vertical";
              padding = mkLiteral "1.5em";
              spacing = mkLiteral "1.5em";
              width = mkLiteral "6.6em";
              background-color = mkLiteral "transparent";
            };
            "button" = {
              cursor = mkLiteral "pointer";
              border-radius = mkLiteral "2em";
              background-color = mkLiteral "@bg";
              text-color = mkLiteral "@foreground";
            };
            "button selected" = {
              background-color = mkLiteral "@selected";
              text-color = mkLiteral "@foreground";
            };
            "element" = {
              enabled = true;
              spacing = mkLiteral "0em";
              padding = mkLiteral "0.5em";
              cursor = mkLiteral "pointer";
              background-color = mkLiteral "transparent";
              text-color = mkLiteral "@foreground";
            };
            "element selected.normal" = {
              background-color = mkLiteral "@selected";
              text-color = mkLiteral "@foreground";
              border-radius = mkLiteral "1.5em";
            };
            "element normal.normal" = {
              background-color = mkLiteral "inherit";
              text-color = mkLiteral "@foreground";
            };
            "element normal.urgent" = {
              background-color = mkLiteral "inherit";
              text-color = mkLiteral "@foreground";
            };
            "element normal.active" = {
              background-color = mkLiteral "inherit";
              text-color = mkLiteral "@foreground";
            };
            "element selected.urgent" = {
              background-color = mkLiteral "inherit";
              text-color = mkLiteral "@foreground";
            };
            "element selected.active" = {
              background-color = mkLiteral "inherit";
              text-color = mkLiteral "@foreground";
            };
            "element-icon" = {
              background-color = mkLiteral "transparent";
              text-color = mkLiteral "inherit";
              size = mkLiteral "3em";
              cursor = mkLiteral "inherit";
            };
            "element-text" = {
              background-color = mkLiteral "transparent";
              text-color = mkLiteral "inherit";
              cursor = mkLiteral "inherit";
              vertical-align = mkLiteral "0.5";
              horizontal-align = mkLiteral "0.1";
            };
            "message" = {
              background-color = mkLiteral "transparent";
              spacing = mkLiteral "0.5em";
              padding = mkLiteral "1em";
              size = mkLiteral "2em";
            };
            "error-message" = {
              text-transform = mkLiteral "capitalize";
              background-color = mkLiteral "@bg";
              text-color = mkLiteral "@foreground";
              children = map mkLiteral [ "textbox" ];
            };
            "textbox" = {
              background-color = mkLiteral "@bg";
              text-color = mkLiteral "@foreground";
              vertical-align = mkLiteral "0.5";
              horizontal-align = mkLiteral "0.0";
            };
          };
      };
    };
}
