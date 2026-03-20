# newModules/home/shell/hm-find.nix
{ ... }: {
  flake.modules.homeManager.hmFind = { pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "hm-find";
        runtimeInputs = [ pkgs.gawk ];
        text = ''
          echo "==============================================="
          echo "            ⚠️  WARNING ⚠️             "
          echo "==============================================="
          echo "This script finds backup files blocking Home Manager rebuilds."
          echo "Deletions are logged to ~/hm-logs."
          echo "==============================================="

          TIME_RANGE="30m"
          LOG_DIR="$HOME/hm-logs"
          LOG_FILE="$LOG_DIR/hm-cleanup-$(date +'%Y-%m-%d_%H-%M-%S').log"

          mkdir -p "$LOG_DIR"

          FILES=$(journalctl --since "-$TIME_RANGE" -xe \
            | grep hm-activate \
            | awk -F "'|'" '/would be clobbered by backing up/ {print $2}')

          if [ -z "$FILES" ]; then
            echo "No conflicting backup files found in the last $TIME_RANGE."
            exit 0
          fi

          echo "🚨 Backup files blocking Home Manager:"
          echo "$FILES" | tr ' ' '\n'

          read -rp "❓ Remove these files? (y/N): " confirm
          if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            echo "🗑️  Deleting files..." | tee -a "$LOG_FILE"
            echo "$FILES" | xargs rm -v | tee -a "$LOG_FILE"
            echo "✅ Cleanup completed at $(date)" | tee -a "$LOG_FILE"
          else
            echo "⛔ No files were removed." | tee -a "$LOG_FILE"
          fi
        '';
      })
    ];
  };
}