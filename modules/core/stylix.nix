{
  pkgs,
  host,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) stylixImage;
in {
  # Styling Options
  stylix = {
    enable = true;
    image = stylixImage;
    base16Scheme = { 
      base00 = "0D0E15"; #0D0E15 
      base01 = "2472c8"; #2472c8
      base02 = "4d4f68"; #4d4f68
      base03 = "626483"; #626483
      base04 = "62d6e8"; #62d6e8
      base05 = "e9e9f4"; #e9e9f4
      base06 = "f1f2f8"; #f1f2f8
      base07 = "f7f7fb"; #f7f7fb
      base08 = "ea51b2"; #ea51b2
      base09 = "b45bcf"; #b45bcf
      base0A = "FFFFFF"; #FFFFFF
      base0B = "ebff87"; #ebff87
      base0C = "a1efe4"; #a1efe4
      base0D = "62d6e8"; #62d6e8
      base0E = "b45bcf"; #b45bcf
      base0F = "000000"; #000000
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
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
