# Flake-parts module exposing a NixOS module for network configuration.
# Includes NetworkManager, firewall rules, and the NetworkManager system 
# tray applet.
#
# Usage:
#   Add self.nixosModules.networking to your host's modules list,
#   then set the hostname in your host module:
#
#   network-config.hostName = "brick";
{ ... }: {
  flake.nixosModules.networking = { config, lib, pkgs, ... }: {
    options.network-config = {
      hostName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The hostname for this machine.";
        example = "brick";
      };
    };

    config = {
      assertions = [
        {
          assertion = config.network-config.hostName != null;
          message = ''
            network-config.hostName is not set.
            As an example, add the following to 
            your host module where 
            nixosModules.networking is imported:
              network-config.hostName = "brick";
          '';
        }
      ];

      networking = {
        hostName = lib.mkIf
          (config.network-config.hostName != null)
          config.network-config.hostName;

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
  };
}