# system/desktop/desktop-programs.nix
# System-level program options required by the desktop environment.
# Actual configuration lives in home/programs/.
{ ... }: {
  flake.nixosModules.desktopPrograms = { pkgs, ... }: {
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

    # TODO: change this to something else when I switch from hyprland 
    services.xserver.enable = false;
    # xdg.portal = {
    #   enable = true;
    #   extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    #   configPackages = [ pkgs.hyprland ];
    # };
  };
}