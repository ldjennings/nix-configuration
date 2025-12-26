{ host, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix) animChoice;
in
{
  imports = [
    animChoice
    ./binds.nix
    ./binds-scripts.nix
    ./env.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./pyprland.nix
    ./windowrules.nix
  ];
}
