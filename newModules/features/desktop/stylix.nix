# Flake-parts module for system theming via Stylix.
# Applies a consistent base16 color scheme across GTK apps,
# terminals, and other supported applications.
# Requires stylix flake input.
{ inputs, ... }: {
  flake.nixosModules.stylix = { pkgs, ... }: {
    imports = [ inputs.stylix.nixosModules.stylix ];
    stylix = {
      enable = true;

      # Set your wallpaper image here
      image = ../../../wallpapers/astronaut_jellyfish.jpg;

      # Custom base16 color scheme
      base16Scheme = {
        base00 = "0D0E15"; # background
        base01 = "2472c8"; # lighter background
        base02 = "4d4f68"; # selection background
        base03 = "626483"; # comments
        base04 = "62d6e8"; # dark foreground
        base05 = "e9e9f4"; # foreground
        base06 = "f1f2f8"; # light foreground
        base07 = "f7f7fb"; # light background
        base08 = "ea51b2"; # red/pink -- errors
        base09 = "b45bcf"; # orange/purple
        base0A = "FFFFFF"; # yellow -- warnings
        base0B = "ebff87"; # green -- success
        base0C = "a1efe4"; # cyan
        base0D = "62d6e8"; # blue -- info
        base0E = "b45bcf"; # magenta
        base0F = "000000"; # deprecated
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