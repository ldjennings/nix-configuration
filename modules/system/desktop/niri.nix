# system/desktop/niri.nix
{inputs, ...}: {
  flake.nixosModules.niri = _: {
    # imports = [ inputs.niri.nixosModules.niri ];

    nixpkgs.overlays = [inputs.niri.overlays.niri];

    # programs.niri = {
    #   # enable = true;
    #   package = pkgs.niri-stable;
    # };

    # xdg.portal = {
    #   enable = true;
    #   extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    #   configPackages = [ pkgs.niri-stable ];
    # };
  };
}
