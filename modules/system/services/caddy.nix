# Reverse proxy giving each service a clean HTTPS name instead of a port.
# Names resolve via Pi-hole's local records (see pihole.nix) to the box, and
# Caddy routes by Host header to the local service port.
#
# TLS is a real Let's Encrypt wildcard for *.jenningsliamd.me, obtained by
# security.acme over the DNS-01 challenge (see acme.nix) -- so browsers trust
# it with no warnings, despite none of this being reachable from the internet.
#
# The explicit `tls` directive also stops Caddy's automatic HTTPS from trying
# to issue its own certificate (it can't: HTTP-01 would need inbound internet
# access). Port 80 stays open so Caddy can redirect plain HTTP to HTTPS.
#
# Caddy terminates TLS for everything; the backends stay plain HTTP bound to
# localhost, which is why they need no certificates of their own.
_: {
  flake.nixosModules.caddy = {config, ...}: let
    certDir = config.security.acme.certs."jenningsliamd.me".directory;

    # A name served over HTTPS with the wildcard cert, proxied to a local port.
    # Caddy forwards websockets transparently, which HA's frontend needs.
    proxyTo = port: {
      extraConfig = ''
        tls ${certDir}/fullchain.pem ${certDir}/key.pem
        reverse_proxy localhost:${toString port}
      '';
    };
  in {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "jellyfin.jenningsliamd.me" = proxyTo 8096;
        "files.jenningsliamd.me" = proxyTo 3210;
        "paperless.jenningsliamd.me" = proxyTo 28981;
        "home.jenningsliamd.me" = proxyTo 8123;
        "pihole.jenningsliamd.me".extraConfig = ''
          tls ${certDir}/fullchain.pem ${certDir}/key.pem
          redir / /admin
          reverse_proxy localhost:8081
        '';
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
