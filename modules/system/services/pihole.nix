# Network-wide DNS ad/tracker blocking via Pi-hole (FTL + web UI).
#
# Usage:
#   Add self.nixosModules.pihole to a host's modules list, then point clients
#   at this box's IP as their DNS server -- per-device (phone Wi-Fi settings)
#   or, better, set the router's upstream DNS to this box so the whole LAN is
#   covered automatically. Reachable over the tailnet too (see tailscale.nix),
#   so it works as your DNS from anywhere you're connected to Tailscale.
#
#   Admin UI: http://<host>/admin  (set the password once with `pihole setpassword`).
_: {
  flake.nixosModules.pihole = _: {
    services.pihole-ftl = {
      enable = true;
      # Open DNS (53) for LAN + tailnet clients and the web UI ports (80/443).
      # Behind home-router NAT this is fine; do not expose port 53 to the
      # public internet (open resolvers get abused).
      openFirewallDNS = true;
      openFirewallWebserver = true;
      settings = {
        dns = {
          # Upstream resolvers queries are forwarded to (Quad9 + Cloudflare).
          upstreams = ["9.9.9.9" "1.1.1.1"];
          # Answer queries arriving on ANY interface/subnet, not just the local
          # one. Needed so clients on other subnets can use us -- notably the
          # tailnet (100.64.0.0/10), whose source IPs aren't on the LAN subnet.
          listeningMode = "ALL";
        };
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
      ports = ["80" "443s"];
    };
  };
}
