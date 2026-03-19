{ ... }:
# let
#   inherit (import ../../hosts/${host}/variables.nix) waybarChoice;
# in
{
  imports = [
    # ./amfora.nix
    # ./bash.nix
    # ./bashrc-personal.nix
    # ./bat.nix
    # ./btop.nix
    # ./cava.nix
    # ./easyeffects
    # ./emoji.nix
    # ./eza.nix
    # ./fastfetch
    # ./formula.nix
    # ./fzf.nix
    # ./gh.nix
    # ./ghostty.nix
    # ./git.nix
    # ./gtk.nix
    # ./htop.nix
    ./hyprland
    # ./kitty.nix
    # ./lazygit.nix
    # ./nvf.nix
    # ./rofi
    # ./qt.nix
    ./scripts
    # ./starship.nix
    # ./stylix.nix
    # ./swappy.nix
    ./swaync.nix
    # ./virtmanager.nix
    # waybarChoice
    ../../modules/home/waybar/waybar-ddubs.nix
    # ./wezterm.nix
    ./wlogout
    # ./xdg.nix
    # ./yazi
    # ./zoxide.nix
    # ./zshg
  ];
}
