# Flake-parts module exposing a NixOS module for mDNS/DNS-SD via Avahi.
# Advertises this machine on the LAN as <hostname>.local and resolves other
# .local hosts, so it can be reached by name instead of a memorized IP.
#
# Usage:
#   Add self.nixosModules.avahi to your host's modules list.
_: {
  flake.nixosModules.avahi = _: {
    services.avahi = {
      enable = true;
      # resolve .local hostnames via nss (getaddrinfo, so ssh/ping/etc. work)
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
      # advertise over the LAN interface(s)
      openFirewall = true;
    };
  };
}
