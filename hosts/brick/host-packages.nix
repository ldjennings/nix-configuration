{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    audacity
    calibre
    legcord
    vscode-fhs
    firefox
    kicad
    hyprpicker
    # direnv
    nil
    nautilus
    alejandra
    obsidian
    inkscape
    qucs-s
    freecad
    vlc
    kdePackages.kdenlive
    libreoffice
    lutris
    # mullvad
    qbittorrent
    zoom-us
  ];
}
