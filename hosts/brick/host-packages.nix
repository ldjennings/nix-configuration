{ pkgs, ... }:
{

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # List by default
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
      
      xorg.libXcomposite
      xorg.libXtst
      xorg.libXrandr
      xorg.libXext
      xorg.libX11
      xorg.libXfixes
      libGL
      libva
      pipewire
      xorg.libxcb
      xorg.libXdamage
      xorg.libxshmfence
      xorg.libXxf86vm
      libelf
    ];
  };

  environment.systemPackages = with pkgs; [
    audacity
    calibre
    legcord
    vscode-fhs
    # vscodium
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
    qalculate-gtk
    qbittorrent
    tinymist
    zoom-us
  ];
}
