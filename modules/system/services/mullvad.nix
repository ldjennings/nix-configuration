# flake/mullvad.nix
# Mullvad VPN client and daemon.
# TODO: make a networking folder or something
{ ... }: {
  flake.nixosModules.mullvad = { pkgs, ... }: {
    services.mullvad-vpn.enable = true;
    environment.systemPackages = with pkgs; [ mullvad ];
  };
}