# system/programs/desktop-utils.nix
# Fundamental graphical utilities for any desktop system.
# The GUI equivalent of cli-utils.nix -- tools useful on any Wayland
# machine before home-manager is configured, or on minimal setups.
{ ... }: {
  flake.nixosModules.desktopUtils = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Browser -- useful before a proper HM browser config is set up
      ungoogled-chromium

      # Display management
      nwg-displays    # monitor configuration GUI for wlroots/Niri

      # Media playback
      mpv             # video player
      ffmpeg          # video and audio processing

      # Audio
      pavucontrol     # PipeWire/PulseAudio volume control

      # Notifications
      libnotify       # needed by scripts and system services

      # Wayland/compositor utilities
      socat           # socket utility, needed for Hyprland scripts

      # Image viewing
      nsxiv           # lightweight image viewer

      # Debugging/diagnostics
      mesa-demos      # GPU testing (glxinfo, glxgears)
    ];
  };
}