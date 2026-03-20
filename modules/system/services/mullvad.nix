# flake/mullvad.nix
# Mullvad VPN client and daemon.
_: {
  flake.nixosModules.mullvad = { pkgs, ... }: {
    services.mullvad-vpn.enable = true;
    environment.systemPackages = with pkgs; [ mullvad ];
  };
}