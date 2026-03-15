# Flake-parts module exposing a NixOS module for network configuration.
# Includes NetworkManager, NTP time servers, firewall rules, and the
# NetworkManager system tray applet.
#
# networking.hostName must be set somewhere outside of this.
{
  flake.nixosModules.networking = {
    pkgs,
    ...
  }: {
    networking = {
      # Enable NetworkManager for managing wifi/ethernet connections
      networkmanager.enable = true;

      firewall = {
        enable = true;
        allowedTCPPorts = [
          22    # SSH
          80    # HTTP
          443   # HTTPS
          # 59010 # Moonlight/Sunshine game streaming
          # 59011 # Moonlight/Sunshine game streaming
          # 8080  # HTTP alternate / dev servers
        ];
        allowedUDPPorts = [
          # 59010 # Moonlight/Sunshine game streaming
          # 59011 # Moonlight/Sunshine game streaming
        ];
      };
    };

    # NetworkManager system tray applet for managing connections via GUI
    environment.systemPackages = with pkgs; [ networkmanagerapplet ];
  };
}
