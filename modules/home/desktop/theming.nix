# newModules/home/theming.nix
_: {
  flake.modules.homeManager.theming = { pkgs, ... }: {
    # Icon theme -- only thing stylix doesn't manage
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };

    qt.enable = true;

    # Disable stylix auto-theming for apps we configure manually
    stylix.targets = {
      waybar.enable = false;
      rofi.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      qt.enable = true;
    };
  };
}