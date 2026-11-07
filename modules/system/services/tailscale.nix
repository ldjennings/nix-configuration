# Tailscale mesh VPN. Gives the host a stable 100.x tailnet address reachable
# from any of your devices, wherever they are. Used by both hosts: minifridge
# so its services (Jellyfin, Paperless, Pi-hole DNS) work off the home LAN
# without exposing ports, and brick so it can reach them from anywhere.
#
# One-time setup per host: run `sudo tailscale up` and authenticate. To use
# Pi-hole as DNS over the tailnet, set minifridge as the tailnet's nameserver
# in the Tailscale admin console. The tailscale0 interface is trusted, so
# tailnet peers reach DNS (53) and the other service ports without extra
# firewall rules.
#
# useRoutingFeatures is left at "none", which is all that plain
# peer-to-peer access needs. Using an exit node additionally needs "client"
# (sets reverse path filtering to loose); advertising one needs "server"
# (enables IP forwarding).
_: {
  flake.nixosModules.tailscale = _: {
    services.tailscale = {
      enable = true;
      # Opens the UDP port used for direct (non-relayed) connections.
      openFirewall = true;
    };

    # Trust anything arriving over the tailnet -- it's already authenticated by
    # Tailscale, and this lets tailnet clients hit DNS/service ports that are
    # otherwise only opened on the LAN.
    networking.firewall.trustedInterfaces = ["tailscale0"];
  };
}
