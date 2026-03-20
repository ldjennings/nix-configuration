# flake/fonts.nix
_: {
  flake.nixosModules.fonts = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans # CJK support -- needed for Chinese input with fcitx5
      font-awesome
      symbola
      material-icons
      fira-code-symbols
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
    ];
  };
}
