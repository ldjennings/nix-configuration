# system/desktop/desktop-programs.nix
# System-level program options required by the desktop environment.
# Actual configuration lives in home/programs/.
_: {
  flake.nixosModules.desktopPrograms = _: {
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
    
    services.xserver.enable = false;
  };
}