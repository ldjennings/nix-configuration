# flake/programs/utils.nix
# Flake-parts module for terminal and headless utilities.
# Useful on any machine regardless of desktop environment.
{ ... }: {
  flake.nixosModules.terminal-utils = { pkgs, ... }: {
    programs = {
      # mtr -- network diagnostic tool (ping + traceroute combined)
      mtr.enable = true;

      # adb -- Android Debug Bridge for Android device access
      adb.enable = true;

      # GPG agent with SSH support for key management
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    environment.systemPackages = with pkgs; [
      # System monitoring
      htop          # interactive process viewer
      lm_sensors    # hardware temperature monitoring
      lshw          # detailed hardware information
      inxi          # CLI system information
      pciutils      # PCI device inspection
      usbutils      # USB device inspection

      # File management
      unzip         # zip archive handling
      unrar         # rar archive handling
      duf           # disk usage overview
      ncdu          # disk usage TUI navigator
      eza           # modern ls replacement

      # Network
      wget          # file fetching via URL

      # Development utilities
      pkg-config    # build system helper for finding library paths
      ripgrep       # fast grep replacement, used by Helix global search
      killall       # kill all instances of a process by name
      git           # git

      # Media processing
      ffmpeg        # video and audio processing

      # Editor
      helix         # primary terminal editor
    ];
  };
}