{inputs, ...}: {
  flake.nixosModules.stylix = {pkgs, ...}: {
    imports = [inputs.stylix.nixosModules.stylix];
    stylix = {
      enable = true;
      image = ../../../wallpapers/astronaut_jellyfish.jpg;
      base16Scheme = "${inputs.tinted-schemes}/base16/catppuccin-macchiato.yaml";
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
