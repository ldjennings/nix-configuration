{ inputs, ... }:
let
  # Named colors -- edit these to change the scheme
  # referenced from https://github.com/chriskempson/base16/blob/main/styling.md
  background    = "#0D0E15";  # base00 -- main background
  altBackground = "#2472c8";  # base01 -- statusbars, line numbers
  selection     = "#4d4f68";  # base02 -- selection background
  comments      = "#626483";  # base03 -- comments, invisibles
  darkFg        = "#62d6e8";  # base04 -- dark foreground
  foreground    = "#e9e9f4";  # base05 -- main foreground
  lightFg       = "#f1f2f8";  # base06 -- light foreground
  lightBg       = "#f7f7fb";  # base07 -- light background
  red           = "#ea51b2";  # base08 -- errors, deletions
  orange        = "#b45bcf";  # base09 -- integers, booleans
  yellow        = "#FFFFFF";  # base0A -- warnings, classes
  green         = "#ebff87";  # base0B -- success, strings
  cyan          = "#a1efe4";  # base0C -- escaped chars, regex
  blue          = "#62d6e8";  # base0D -- functions, headings
  magenta       = "#b45bcf";  # base0E -- keywords
  deprecated    = "#000000";  # base0F -- deprecated, embedded

  # Strip leading # for stylix (which doesn't want it)
  s = str:
    if builtins.substring 0 1 str == "#"
    then builtins.substring 1 (builtins.stringLength str - 1) str
    else str;
in {
  flake.nixosModules.stylix = { pkgs, ... }: {
    imports = [ inputs.stylix.nixosModules.stylix ];
    stylix = {
      enable = true;
      image = ../../../wallpapers/astronaut_jellyfish.jpg;
      base16Scheme = {
        base00 = s background;
        base01 = s altBackground;
        base02 = s selection;
        base03 = s comments;
        base04 = s darkFg;
        base05 = s foreground;
        base06 = s lightFg;
        base07 = s lightBg;
        base08 = s red;
        base09 = s orange;
        base0A = s yellow;
        base0B = s green;
        base0C = s cyan;
        base0D = s blue;
        base0E = s magenta;
        base0F = s deprecated;
      };
      polarity = "dark";
      opacity.terminal = 1.0;
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrains Mono";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "noto";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "noto";
        };
        sizes = {
          applications = 10;
          terminal = 15;
          desktop = 11;
          popups = 12;
        };
      };
    };
  };
}