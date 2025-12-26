{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "brightness-gamma" ''
      #!/usr/bin/env bash
      set -euo pipefail

      BRIGHTNESS_EXPONENT=2.2
      BRIGHTNESS_STEP=5
      GAMMA_STEP=10
      GAMMA_FLOOR=60

      read_brightness_info() {
        line="$(${pkgs.brightnessctl}/bin/brightnessctl \
          --exponent="$BRIGHTNESS_EXPONENT" -m i | head -n1)"

        IFS=, read -r DEVICE CLASS BRIGHT_RAW BRIGHT_PCT BRIGHT_MAX <<EOF
$line
EOF

        BRIGHT_PCT="''${BRIGHT_PCT%\%}"

        GAMMA_RAW="$(${pkgs.hyprland}/bin/hyprctl hyprsunset gamma)"
        GAMMA="$(printf "%.0f" "$GAMMA_RAW")"
      }

      read_brightness_info

      case "''${1:-}" in
        down)
          if [ "$BRIGHT_PCT" -gt "$BRIGHTNESS_STEP" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl \
              --exponent="$BRIGHTNESS_EXPONENT" set "''${BRIGHTNESS_STEP}%-"

          elif [ "$GAMMA" -gt "$GAMMA_FLOOR" ]; then
            ${pkgs.hyprland}/bin/hyprctl \
              hyprsunset gamma "-$GAMMA_STEP"

          else
            ${pkgs.brightnessctl}/bin/brightnessctl set 0
          fi
          ;;

        up)
          if [ "$BRIGHT_PCT" -eq 0 ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl \
              --exponent="$BRIGHTNESS_EXPONENT" set "''${BRIGHTNESS_STEP}%"

          elif [ "$BRIGHT_PCT" -le "$BRIGHTNESS_STEP" ] && [ "$GAMMA" -lt 100 ]; then
            ${pkgs.hyprland}/bin/hyprctl \
              hyprsunset gamma "+$GAMMA_STEP"

          else
            ${pkgs.brightnessctl}/bin/brightnessctl \
              --exponent="$BRIGHTNESS_EXPONENT" set "+''${BRIGHTNESS_STEP}%"
          fi
          ;;

        *)
          echo "usage: brightness-gamma {up|down}" >&2
          exit 1
          ;;
      esac
    '')

    (pkgs.writeShellScriptBin "toggle-light-filter" ''
      set -euo pipefail

      BASE_TEMPERATURE=6000
      FILTER_TEMPERATURE=2500

      CURRENT_TEMPERATURE=$(${pkgs.hyprland}/bin/hyprctl hyprsunset temperature)

      if [ "$CURRENT_TEMPERATURE" -le "$FILTER_TEMPERATURE" ]; then
          TARGET="$BASE_TEMPERATURE"
      else
          TARGET="$FILTER_TEMPERATURE"
      fi

      ${pkgs.hyprland}/bin/hyprctl hyprsunset temperature "$TARGET"

      ${pkgs.libnotify}/bin/notify-send "Night Light" "Temperature set to ''${TARGET}K"



    '')
  ];
}
