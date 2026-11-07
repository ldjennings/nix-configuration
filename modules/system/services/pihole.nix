# Network-wide DNS ad/tracker blocking via Pi-hole (FTL + web UI).
#
# Usage:
#   Add self.nixosModules.pihole to a host's modules list, then point clients
#   at this box's IP as their DNS server -- per-device (phone Wi-Fi settings)
#   or, better, set the router's upstream DNS to this box so the whole LAN is
#   covered automatically. Reachable over the tailnet too (see tailscale.nix),
#   so it works as your DNS from anywhere you're connected to Tailscale.
#
#   Admin UI: http://pihole.minifridge.home  (fronted by Caddy; set the
#   password once with `pihole setpassword`).
_: {
  flake.nixosModules.pihole = _: {
    services.pihole-ftl = {
      enable = true;
      # Open DNS (53) for LAN + tailnet clients. The web UI is NOT opened to the
      # LAN -- Caddy (see caddy.nix) reverse-proxies it over localhost:8081.
      # Behind home-router NAT this is fine; do not expose port 53 to the
      # public internet (open resolvers get abused).
      openFirewallDNS = true;
      settings = {
        dns = {
          # Upstream resolvers queries are forwarded to (Quad9 + Cloudflare).
          upstreams = ["9.9.9.9" "1.1.1.1"];
          # Answer queries arriving on ANY interface/subnet, not just the local
          # one. Needed so clients on other subnets can use us -- notably the
          # tailnet (100.64.0.0/10), whose source IPs aren't on the LAN subnet.
          listeningMode = "ALL";
        };
        # Local DNS for the service names, so Caddy can host-route by name and
        # the traffic never leaves the LAN/tailnet. Points at the Tailscale IP
        # so the names also resolve off-LAN for tailnet clients.
        #
        # Deliberately one entry per service rather than a zone-wide
        # address=/jenningsliamd.me/: dnsmasq's address= matches the given
        # domain *and every subdomain*, so a zone-wide entry would also hijack
        # the apex and www for every device using this box as DNS -- which
        # would break the real domain if it ever serves a public site. These
        # leaf names don't exist in Cloudflare at all; only the ACME
        # _acme-challenge TXT records do.
        misc.dnsmasq_lines =
          map (name: "address=/${name}.jenningsliamd.me/100.76.67.107")
          [
            "jellyfin"
            "files"
            "paperless"
            "pihole"
            "home"
          ];
      };
      # Blocklists auto-imported on startup.
      lists = [
        {
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
          type = "block";
          enabled = true;
          description = "hagezi blocklist";
        }
      ];
    };

    services.pihole-web = {
      enable = true;
      # Off :80 so Caddy can own it; reached via http://pihole.minifridge.home.
      ports = ["8081"];
    };
  };
}
