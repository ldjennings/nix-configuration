# Flake-parts module for Thunar file manager.
# Lightweight GTK file manager with archive and volume management plugins.
# ffmpegthumbnailer provides video thumbnail previews in the file browser.
{ ... }: {
  flake.nixosModules.thunar = { pkgs, ... }: {
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin  # right-click archive extraction and compression
        thunar-volman          # automatic management of removable drives
      ];
    };

    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer  # video and image thumbnail generation in Thunar
    ];
  };
}