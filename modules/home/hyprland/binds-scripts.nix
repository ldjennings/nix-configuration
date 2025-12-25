{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "brightness-gamma" ''
      set -euo pipefail

      STEP_BRIGHTNESS="2%"
      STEP_GAMMA=10

      case "$1" in
        up)
          ${pkgs.brightnessctl}/bin/brightnessctl set +$STEP_BRIGHTNESS
          ${pkgs.hyprland}/bin/hyprctl hyprsunset gamma +$STEP_GAMMA
          ;;
        down)
          ${pkgs.brightnessctl}/bin/brightnessctl set $STEP_BRIGHTNESS-
          ${pkgs.hyprland}/bin/hyprctl hyprsunset gamma -$STEP_GAMMA
          ;;
        *)
          echo "usage: brightness-gamma {up|down}" >&2
          exit 1
          ;;
      esac
    '')
  ];
}
