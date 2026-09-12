# Full-tunnel Mullvad VPN via raw WireGuard, with a hard kill switch, while
# keeping the box reachable from the LAN and the tailnet.
#
# How it works (policy routing, no separate firewall kill switch):
#   - The peer's AllowedIPs = 0.0.0.0/0,::/0, so all traffic is crypto-routed
#     to Mullvad.
#   - Routing table 51820 holds `default dev mullvad` plus a higher-metric
#     `blackhole default`. The blackhole IS the kill switch: if the tunnel
#     drops, its device route disappears and the blackhole drops everything,
#     so nothing leaks to the ISP.
#   - `ip rule ... suppress_prefixlength 0` on the main table makes the kernel
#     still honour every *specific* route the system already has -- the
#     connected LAN subnet and tailscale0's routes -- for both outbound and
#     inbound-reply traffic. So LAN + tailnet keep working even with the tunnel
#     down, and we never hardcode those subnets.
#   - The tunnel's own outer packets are marked (fwmark 51820) and excluded
#     from table 51820, so the WireGuard handshake always reaches the endpoint
#     and can reconnect.
#
# The WireGuard private key is a sops secret (encrypted in the repo, decrypted
# to /run/secrets at activation), so nothing sensitive lands in the Nix store.
# Edit with:  sops secrets/minifridge.yaml   (key mullvad-wg-key)
#
# Get the values below + the private key from mullvad.net -> WireGuard
# configuration (or the `mullvad` CLI).
_: {
  flake.nixosModules.mullvad = {
    pkgs,
    config,
    ...
  }: let
    ip = "${pkgs.iproute2}/bin/ip";
    wg = "${pkgs.wireguard-tools}/bin/wg";

    # ---- Mullvad WireGuard parameters (TODO: replace placeholders) ----------
    address4 = "10.0.0.0/32"; # [Interface] Address, IPv4 (/32)
    address6 = "fc00:0000:0000:0000:0000:0000:0000:0001/128"; # [Interface] Address, IPv6 (/128)
    serverPublicKey = "REPLACE_WITH_PEER_PUBLICKEY="; # [Peer] PublicKey
    endpoint = "0.0.0.0:51820"; # [Peer] Endpoint (use the numeric IP:port)
    # -------------------------------------------------------------------------
  in {
    sops.secrets."mullvad-wg-key" = {};

    networking.wireguard.interfaces.mullvad = {
      ips = [address4 address6];
      privateKeyFile = config.sops.secrets."mullvad-wg-key".path;
      # We install our own policy routing below instead of letting the module
      # turn AllowedIPs into (main-table) routes.
      allowedIPsAsRoutes = false;

      peers = [
        {
          publicKey = serverPublicKey;
          allowedIPs = ["0.0.0.0/0" "::/0"];
          inherit endpoint;
          persistentKeepalive = 25;
        }
      ];

      postSetup = ''
        ${wg} set mullvad fwmark 51820

        # IPv4: full tunnel + blackhole kill switch, honouring specific routes.
        ${ip} -4 route add default dev mullvad table 51820
        ${ip} -4 route add blackhole default table 51820 metric 1000
        ${ip} -4 rule add priority 51810 table main suppress_prefixlength 0
        ${ip} -4 rule add priority 51820 not fwmark 51820 table 51820

        # IPv6: same, so v6 can't leak around the tunnel either.
        ${ip} -6 route add default dev mullvad table 51820
        ${ip} -6 route add blackhole default table 51820 metric 1000
        ${ip} -6 rule add priority 51810 table main suppress_prefixlength 0
        ${ip} -6 rule add priority 51820 not fwmark 51820 table 51820
      '';

      postShutdown = ''
        ${ip} -4 rule del priority 51820 table 51820 || true
        ${ip} -4 rule del priority 51810 table main suppress_prefixlength 0 || true
        ${ip} -6 rule del priority 51820 table 51820 || true
        ${ip} -6 rule del priority 51810 table main suppress_prefixlength 0 || true
        ${ip} -4 route flush table 51820 || true
        ${ip} -6 route flush table 51820 || true
      '';
    };
  };
}
