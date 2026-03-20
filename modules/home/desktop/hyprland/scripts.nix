# newModules/home/desktop/hyprland/scripts.nix
_: {
  flake.modules.homeManager.hyprland = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "brightness-gamma";
        runtimeInputs = [pkgs.brightnessctl pkgs.hyprland];
        text = ''
          BRIGHTNESS_EXPONENT=2.2
          BRIGHTNESS_STEP=5
          GAMMA_STEP=10
          GAMMA_FLOOR=60

          read_brightness_info() {
            line="$(brightnessctl --exponent="$BRIGHTNESS_EXPONENT" -m i | head -n1)"
            IFS=, read -r _DEVICE _CLASS _BRIGHT_RAW BRIGHT_PCT _BRIGHT_MAX <<EOF
          $line
          EOF
            BRIGHT_PCT="''${BRIGHT_PCT%\%}"
            GAMMA_RAW="$(hyprctl hyprsunset gamma)"
            GAMMA="$(printf "%.0f" "$GAMMA_RAW")"
          }

          read_brightness_info

          case "''${1:-}" in
            down)
              if [ "$BRIGHT_PCT" -gt "$BRIGHTNESS_STEP" ]; then
                brightnessctl --exponent="$BRIGHTNESS_EXPONENT" set "''${BRIGHTNESS_STEP}%-"
              elif [ "$GAMMA" -gt "$GAMMA_FLOOR" ]; then
                hyprctl hyprsunset gamma "-$GAMMA_STEP"
              else
                brightnessctl set 0
              fi
              ;;
            up)
              if [ "$BRIGHT_PCT" -eq 0 ]; then
                brightnessctl --exponent="$BRIGHTNESS_EXPONENT" set "''${BRIGHTNESS_STEP}%"
              elif [ "$BRIGHT_PCT" -le "$BRIGHTNESS_STEP" ] && [ "$GAMMA" -lt 100 ]; then
                hyprctl hyprsunset gamma "+$GAMMA_STEP"
              else
                brightnessctl --exponent="$BRIGHTNESS_EXPONENT" set "+''${BRIGHTNESS_STEP}%"
              fi
              ;;
            *)
              echo "usage: brightness-gamma {up|down}" >&2
              exit 1
              ;;
          esac
        '';
      })

      (pkgs.writeShellApplication {
        name = "toggle-light-filter";
        runtimeInputs = [pkgs.hyprland pkgs.libnotify];
        text = ''
          BASE_TEMPERATURE=6000
          FILTER_TEMPERATURE=1500

          CURRENT_TEMPERATURE=$(hyprctl hyprsunset temperature)

          if [ "$CURRENT_TEMPERATURE" -le "$FILTER_TEMPERATURE" ]; then
            TARGET="$BASE_TEMPERATURE"
          else
            TARGET="$FILTER_TEMPERATURE"
          fi

          hyprctl hyprsunset temperature "$TARGET"
          notify-send "Night Light" "Temperature set to ''${TARGET}K"
        '';
      })
    ];
  };
}
