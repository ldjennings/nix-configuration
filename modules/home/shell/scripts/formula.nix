# newModules/home/formula.nix
# FSAE team utilities -- inventory lookup and KiCad project opener.
# API token for inv-query should be set via a secrets manager (agenix/sops-nix)
# before deploying to a machine with a public config repo.
_: {
  flake.modules.homeManager.formula = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "inv-query";
        runtimeInputs = [pkgs.zsh pkgs.curl pkgs.jq pkgs.libnotify];
        text = ''
          if [[ "''${1:-}" = "-r" ]]; then
            (
              curl -H "Authorization: Token 6fd451d3a0576f941c43df42b1e016be048466fd" "http://collabserver.org:10003/api/part/.*" \
                | jq -r '.[] | select(.IPN != "") | .IPN + "   " + .name' \
                > ~/.cache/fsae/inv-new.txt
            ) && mv ~/.cache/fsae/inv-new.txt ~/.cache/fsae/inv.txt \
              && notify-send "Inventory Updated" &
          fi

          IPN=$(cat ~/.cache/fsae/inv.txt \
            | rofi -dmenu -i -matching-negate-char '\0' \
            | sed 's/ .*//')

          [[ -n "$IPN" ]] && firefox "http://collabserver.org:10003/part/$IPN/"
        '';
      })

      (pkgs.writeShellApplication {
        name = "ki-open";
        runtimeInputs = [pkgs.tree pkgs.kicad];
        text = ''
          PROJECT=$(tree ~/projects -fi \
            | grep .kicad_pro \
            | sed 's/\.\///' \
            | rofi -dmenu -i -matching-negate-char '\0')

          [[ -n "$PROJECT" ]] && kicad "$PROJECT"
        '';
      })
    ];

    xdg.desktopEntries = {
      inv-query = {
        name = "inv-query";
        genericName = "Rofi Selector";
        exec = "inv-query";
        terminal = false;
        type = "Application";
      };
      ki-open = {
        name = "ki-open";
        genericName = "Rofi Selector";
        exec = "ki-open";
        terminal = false;
        type = "Application";
      };
    };
  };
}
