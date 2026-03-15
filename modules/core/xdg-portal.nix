{ pkgs, ... }:
{
  # TODO: make this a part of hyprland/niri module probably
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    configPackages = [ pkgs.hyprland ];
  };
}
