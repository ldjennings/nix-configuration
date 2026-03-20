# system/programs/cli-utils.nix
# Essential CLI tools for interactive shell sessions.
# Installed system-wide so they're available on any machine regardless
# of whether home-manager is configured -- particularly useful over SSH
# or on fresh installs before dotfiles are set up.
_: {
  flake.nixosModules.cliUtils = { pkgs, ... }: {
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      # Version control -- needed to bootstrap the nix config itself
      git

      # Shell session management -- keeps sessions alive over SSH disconnects
      tmux

      # Filesystem navigation
      yazi     # terminal file manager
      eza      # better ls
      tree     # quick directory overview, useful without yazi configured

      # Search
      ripgrep  # better grep

      # Disk usage
      duf      # quick disk overview
      ncdu     # interactive drill-down

      # Archive handling
      unzip
      unrar

      # Network
      wget
      curl

      # Data processing
      jq       # JSON parsing, useful for API responses and flake metadata

      # System info
      htop          # interactive process viewer
      inxi     # quick hardware/system summary

      # Process management
      killall

      # File identification
      file     # identify file types by magic bytes
    ];
  };
}