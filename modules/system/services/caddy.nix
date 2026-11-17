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
    certName = "jenningsliamd.me";
    certDir = config.security.acme.certs.${certName}.directory;

    # A name served over HTTPS with the wildcard cert, proxied to a backend.
    # Caddy forwards websockets transparently, which HA's frontend needs.
    proxyToHost = host: port: {
      extraConfig = ''
        tls ${certDir}/fullchain.pem ${certDir}/key.pem
        reverse_proxy ${host}:${toString port}
      '';
    };

    # Most backends are on this box, bound to localhost.
    proxyTo = proxyToHost "localhost";
  in {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "jellyfin.jenningsliamd.me" = proxyTo 8096;
        "files.jenningsliamd.me" = proxyTo 3210;
        "paperless.jenningsliamd.me" = proxyTo 28981;
        "home.jenningsliamd.me" = proxyTo 8123;
        # The VPN sandbox container, across its veth (see sandbox.nix -- the
        # address and port are defined there). This is the container's only
        # ingress: nothing is opened to the LAN for it. Returns 502 until a
        # service is actually declared inside the container, which is a
        # convenient way to prove the DNS/TLS/routing path works first.
        "sandbox.jenningsliamd.me" = proxyToHost "10.100.0.2" 8080;
        "pihole.jenningsliamd.me".extraConfig = ''
          tls ${certDir}/fullchain.pem ${certDir}/key.pem
          redir / /admin
          reverse_proxy localhost:8081
        '';
      };
    };

    # Caddy refuses to load a config whose `tls` files don't exist, so it must
    # not start before acme-${certName}.service has written them. That service
    # drops a self-signed placeholder immediately (the real cert replaces it
    # when lego finishes, via reloadServices in acme.nix), so this ordering is
    # enough -- Caddy never has to wait on DNS-01 propagation.
    #
    # Learned the hard way: on the first activation switch-to-configuration
    # reloaded Caddy one second *before* the placeholder existed, Caddy aborted
    # with "open .../fullchain.pem: no such file or directory", and that failed
    # the whole activation. Ordering doesn't govern reloads of an
    # already-running unit, but the cert files persist in /var/lib/acme, so the
    # race only exists on a machine that has never had them -- where this
    # boot-time ordering is exactly what prevents it.
    systemd.services.caddy = {
      after = ["acme-${certName}.service"];
      wants = ["acme-${certName}.service"];
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
