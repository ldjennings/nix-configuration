_: {
  flake.modules.homeManager.desktopApps = {pkgs, ...}: {
    home.packages = with pkgs; [
      audacity
      calibre
      legcord
      vscode-fhs
      firefox
      gimp
      kicad
      hyprpicker
      nautilus
      # Electron 41 crashes Obsidian's renderer on WASM streaming compilation
      # (window renders fully transparent); fixed in Electron >= 42.4.1.
      # Drop the override once nixpkgs' default electron is >= 42.4.1.
      (obsidian.override {electron = electron_42;})
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
      zotero
    ];
  };
}
