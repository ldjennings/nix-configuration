# Reverse proxy giving each service a clean name instead of a port. Names
# resolve via the Pi-hole wildcard record (*.minifridge.home, see pihole.nix)
# to the box, and Caddy routes by Host header to the local service port.
#
# Plain HTTP on purpose: reached over the LAN or the tailnet, and the tailnet
# already encrypts everything at the WireGuard layer, so there's little to gain
# from self-signed TLS here. The "http://" scheme prefix disables Caddy's
# automatic HTTPS (which couldn't get a public cert for these internal names
# anyway). The direct host:port endpoints stay open too.
_: {
  flake.nixosModules.caddy = _: {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "http://jellyfin.minifridge.home".extraConfig = "reverse_proxy localhost:8096";
        "http://files.minifridge.home".extraConfig = "reverse_proxy localhost:3210";
        "http://paperless.minifridge.home".extraConfig = "reverse_proxy localhost:28981";
        "http://pihole.minifridge.home".extraConfig = ''
          redir / /admin
          reverse_proxy localhost:8081
        '';
      };
    };

    networking.firewall.allowedTCPPorts = [80];
  };
}
