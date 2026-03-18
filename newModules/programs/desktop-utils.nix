# flake/programs/desktop.nix
# Flake-parts module for graphical desktop utilities.
# Requires a Wayland compositor or display server.
{ ... }: {
  flake.nixosModules.desktop-utils = { pkgs, ... }: {
    programs = {
      # dconf needed for GTK app settings persistence
      dconf.enable = true;

      # FUSE -- allows mounting filesystems as non-root user
      fuse.userAllowOther = true;

      # Hyprland -- keeping for now during migration to Niri
      hyprland.enable = true;

      # Hyprlock -- Hyprland screen locker, keeping during migration
      hyprlock.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # System
      mesa-demos    # GPU testing (glxinfo, glxgears)
      brightnessctl # screen brightness control
      libnotify     # desktop notification library
      nwg-displays  # monitor configuration GUI for wlroots/Niri
      socat         # socket utility, needed for Hyprland screenshots
      pavucontrol   # PipeWire/PulseAudio volume control GUI
      playerctl     # media player control via CLI/scripts
      v4l-utils     # video4linux utilities for OBS virtual camera

      # File management
      file-roller   # archive manager GUI
      nsxiv         # image viewer, used by yazi for image previews
      gedit         # graphical text editor for use with Thunar

      # Media
      mpv           # video player
      hyprpicker    # color picker for Hyprland/Wayland

      # Browsers
      ungoogled-chromium      # backup browser, works well with Microsoft Teams web app

      # Optional -- uncomment if needed
      gimp        # image editor
      # picard      # music metadata editor
      # rhythmbox   # music player
      # ytmdl       # YouTube audio downloader
    ];
  };
}