{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    audacity
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
  ];
}
