# system/desktop/niri.nix
_: {
  flake.nixosModules.niri = {pkgs, ...}: {
    # nixpkgs module -- installs niri + niri-session and registers the
    # wayland session file that greetd's session picker reads. The package
    # comes from cache.nixos.org, so updates never build niri from source.
    programs.niri.enable = true;

    environment.systemPackages = [
      # niri spawns this on demand to run X11 apps (Steam etc.)
      pkgs.xwayland-satellite
    ];
  };
}
