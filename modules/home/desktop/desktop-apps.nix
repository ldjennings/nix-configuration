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
      # Obsidian needs Electron >= 42.4.1 (earlier versions render the window
      # fully transparent -- a WASM streaming-compilation crash). nixpkgs'
      # default electron is now 43.x, so plain obsidian is fine; the old
      # `electron_42` override is gone because electron_42 is now EOL/insecure.
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
      zotero
    ];
  };
}
