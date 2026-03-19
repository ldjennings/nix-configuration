{ ... }:
{
  flake.modules.homeManager.tempPackages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        audacity
        calibre
        legcord
        vscode-fhs
        firefox
        kicad
        hyprpicker
        nautilus
        obsidian
        inkscape
        qucs-s
        freecad
        vlc
        kdePackages.kdenlive
        libreoffice
        lutris
        qalculate-gtk
        qbittorrent
        tinymist
        typst
        zoom-us
      ];
    };
}
