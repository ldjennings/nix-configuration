{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    audacity
    discord
    nodejs
    obs-studio
    vscode-fhs
    firefox
    kicad
    hyprpicker
    direnv
  ];
}
