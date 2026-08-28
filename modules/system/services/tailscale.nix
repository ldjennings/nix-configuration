# Tailscale mesh VPN. Gives the box a stable 100.x tailnet address reachable
# from any of your devices, wherever they are -- so services (Jellyfin,
# Paperless, Pi-hole DNS) work off the home LAN without exposing ports.
#
# One-time setup after the first deploy: run `sudo tailscale up` on the box and
# authenticate. To use Pi-hole as DNS over the tailnet, set this node as the
# tailnet's nameserver in the Tailscale admin console (or use it as an exit
# node). The tailscale0 interface is trusted, so tailnet clients reach DNS (53)
# and the other service ports without extra firewall rules.
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
