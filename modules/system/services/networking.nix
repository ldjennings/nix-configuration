# Flake-parts module exposing a NixOS module for network configuration.
# Includes NetworkManager, firewall rules, and the NetworkManager system
# tray applet.
#
# Usage:
#   Add self.nixosModules.networking to your host's modules list.
#   Requires host.hostname to be set in your host module:
#
#   host.hostname = "brick";
_: {
  flake.nixosModules.networking = {
    config,
    pkgs,
    ...
  }: {
    # imports = [ self.nixosModules.hostConfig ];
    # imports = [ "${self}/custom-nix-code/host-config.nix" ];

    config = {
      networking = {
        hostName = config.host.hostname;

        # Enable NetworkManager for managing wifi/ethernet connections
        networkmanager.enable = true;

        firewall = {
          enable = true;
          allowedTCPPorts = [
            22 # SSH
            80 # HTTP
            443 # HTTPS
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
      environment.systemPackages = with pkgs; [networkmanagerapplet];
    };
  };
}
