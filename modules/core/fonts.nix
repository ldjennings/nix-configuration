{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      font-awesome
      symbola
      material-icons
      fira-code-symbols
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
    ];
  };
}
