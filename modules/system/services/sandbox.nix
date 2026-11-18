# An isolated NixOS container whose only route to the internet is a Mullvad
# WireGuard tunnel, while it can still reach this host's own services and drop
# files into /srv/media. Currently runs qBittorrent, which downloads into a
# scratch directory and moves each finished torrent into the matching Jellyfin
# library (see `categories` below).
#
# Usage:
#   Add self.nixosModules.sandbox to a host's modules list, fill in the
#   WireGuard parameters below, then declare whatever else should run in the
#   sandbox inside `containers.sandbox.config` (see "ADDING ANOTHER SERVICE").
#
# Shape of the thing:
#
#   container "sandbox"                        host
#     eth0 10.100.0.2/32 ────veth──────── ve-sandbox 10.100.0.1
#      │                                      │
#      ├─ 10.100.0.1       dev eth0           ├─ caddy :443  (ingress)
#      ├─ <endpoint>/32    via host  ─────────┤  nat masquerade -> eno1
#      ├─ default          dev mullvad        ├─ /srv/media/Downloads (bind)
#      └─ blackhole default metric 1000       ├─ /srv/media/{Movies,TV,Music}
#          wg "mullvad" ══════════════════>   └─ /srv/qbittorrent     (bind)
#                    internet
#
# Ingress is Caddy only (caddy.nix proxies sandbox.jenningsliamd.me to
# 10.100.0.2), so no port is ever opened to the LAN for this container.
# Egress is the tunnel only, enforced by the routing table rather than by
# firewall rules: the sole non-tunnel routes are the host veth and a /32 for
# the VPN endpoint, so there is nowhere else for a packet to go.
#
# The blackhole default is the kill switch. `default dev mullvad` has metric 0
# and wins while the tunnel is up; if wireguard stops, the kernel drops that
# route and the metric-1000 blackhole takes over. The link-scope route to the
# host survives, so the sandbox keeps talking to this host's services even with
# the tunnel down -- it just cannot reach the internet.
#
# Verified live after the first deploy: the container's whole v4 routing table
# is those four entries and nothing else, and name resolution works only
# because 10.64.0.1 (Mullvad's internal resolver) is reachable through the
# tunnel -- which is itself the proof that egress has nowhere else to go.
_: {
  flake.nixosModules.sandbox = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # ---- Mullvad WireGuard parameters ---------------------------------------
    # From the config file Mullvad's WireGuard generator produces (mullvad.net
    # -> WireGuard configuration). None of these are secrets: the peer's key
    # and endpoint are public, and address4 is only meaningful to whoever holds
    # the matching private key -- which is the sops secret, not this file.
    #
    # Changing the endpoint moves which exit the traffic appears to come from,
    # and requires the matching serverPublicKey from the same generated file:
    # every relay has its own keypair, so the two must be swapped together.
    #
    # IPv6 is deliberately left out: the container gets no v6 address and no
    # v6 route (see networking.enableIPv6 below), which is one fewer way to
    # leak. Mullvad hands out a v6 address too (fc00:bbbb:...:3:5b73/128 for
    # this key) -- it is simply not used.
    address4 = "10.66.91.116/32"; # [Interface] Address, the IPv4 /32
    serverPublicKey = "RnwTFcAl6z4UfXio9ApLqlOjBcYvD0gWG0htl6fiCl4="; # [Peer] PublicKey
    endpoint = "98.98.47.130:51820"; # [Peer] Endpoint -- must be a numeric IP:port
    # -------------------------------------------------------------------------

    # The endpoint needs its own /32 via the host, so the outer WireGuard
    # packets can escape before the tunnel they create exists. Splitting it out
    # is why no fwmark/policy-routing is needed here, unlike mullvad.nix: the
    # host-wide module has to exempt the handshake from a rule that catches all
    # traffic, whereas one specific route is enough in a namespace this empty.
    endpointAddress = lib.head (lib.splitString ":" endpoint);

    hostAddress = "10.100.0.1";
    localAddress = "10.100.0.2";

    # Port the sandboxed service listens on inside the container; Caddy
    # proxies to it (see caddy.nix). Bind the service to 0.0.0.0, NOT
    # localhost -- Caddy connects from hostAddress across the veth.
    sandboxPort = 8080;

    # Fixed rather than left to qBittorrent's random choice, so the tunnel's
    # traffic is recognisable. Mullvad removed port forwarding in 2023, so no
    # inbound peer connections arrive regardless of what this is -- it only
    # pins the source port for outbound ones.
    torrentPort = 51413;

    # Numeric GID shared with the host's `media` group so files written here
    # are readable by Jellyfin and copyparty. See the comment on the pinned
    # gid in modules/hosts/minifridge/media.nix -- these two must agree, and
    # 997 is what the host already allocated, so existing files keep their
    # group.
    mediaGid = 997;

    mediaDir = "/srv/media";

    # Pure scratch. Incomplete torrents live in incompleteDir; when one
    # finishes, qBittorrent MOVES the files to its category's save path below,
    # so nothing accumulates here and nothing has to be shuffled by hand.
    # Torrents with no category stay in downloadsDir.
    downloadsDir = "${mediaDir}/Downloads";
    incompleteDir = "${downloadsDir}/incomplete";

    # qBittorrent category -> the library directory finished torrents land in.
    # The attribute name is the category label picked when adding a torrent in
    # the WebUI; pick one and the file ends up where Jellyfin already looks.
    # These paths must match the library dirs created in media.nix, which also
    # has to grant the `media` group write access (2770) for this to work --
    # the two files are coupled.
    categories = {
      movies = "${mediaDir}/Movies";
      tv = "${mediaDir}/TV";
      music = "${mediaDir}/Music";
    };

    # Categories are NOT part of qBittorrent.conf -- they live in their own
    # categories.json in the profile, confirmed against qbittorrent-nox 5.2.2.
    # A minimal object carrying just save_path is accepted; qBittorrent fills
    # in the ratio/seeding defaults itself.
    categoriesFile =
      pkgs.writeText "categories.json"
      (builtins.toJSON (lib.mapAttrs (_: path: {save_path = path;}) categories));

    # qBittorrent's profile: its preferences plus the resume data recording
    # which torrents exist and how far along they are. Kept on /srv like
    # paperless' and Home Assistant's state, so rebuilding or deleting the
    # container does not lose the torrent list.
    profileDir = "/srv/qbittorrent";

    ip = "${pkgs.iproute2}/bin/ip";
    wgKeyPath = "/secrets/mullvad-wg-key";
  in {
    # Decrypted on the host and bind-mounted in; the container has no sops key
    # of its own. Edit with: sops secrets/minifridge.yaml (key mullvad-wg-key).
    sops.secrets."mullvad-wg-key" = {};

    # Containers cannot load kernel modules (boot.modprobeConfig.enable is
    # false for them, see nixpkgs' container-config.nix), so the host has to
    # have wireguard available before the container tries to create a wg link.
    boot.kernelModules = ["wireguard"];

    # Masquerade the container's traffic. This exists ONLY so the WireGuard
    # handshake can reach the endpoint -- everything else the sandbox emits is
    # already confined by its routing table, so a permissive NAT rule here
    # does not widen what it can reach. Note this turns on IP forwarding
    # host-wide.
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-sandbox"];
      externalInterface = "eno1";
    };

    # Group-writable with the setgid bit, so the sandbox user can drop files
    # here and everything it writes lands in group `media` automatically. The
    # library directories in media.nix are now the same 2770 for the same
    # reason -- completed torrents get moved into them.
    systemd.tmpfiles.rules = [
      "d ${downloadsDir} 2770 root ${toString mediaGid} -"
      # Mount point for the bind mount below -- nspawn creates the path inside
      # the container but needs the host side to exist. The container's own
      # tmpfiles create the subdirectories under it. Numeric ids because
      # `sandbox` (2000) and `media` (997) are names that exist only on the
      # other side of the mount.
      "d ${profileDir} 0750 2000 ${toString mediaGid} -"
    ];

    containers.sandbox = {
      autoStart = true;
      inherit hostAddress localAddress;

      # Its own network namespace -- without this the container would share
      # the host's networking entirely and the tunnel would be pointless.
      privateNetwork = true;

      # No user namespacing, which is what makes the shared `media` group work:
      # nixpkgs' mkBindFlag does not pass systemd-nspawn's `:idmap` option for
      # these bind mounts (only the /nix ones get it), so under
      # privateUsers = "pick" the mount would appear as nobody:nogroup inside
      # and files written would land on the host owned by a shifted UID.
      #
      # The cost is real and worth naming: root in this container is root on
      # the host. The isolation here is network and process, not privilege.
      # Treat the sandbox as "trusted code whose traffic should be hidden",
      # not as a place to run something hostile -- that wants a VM.
      privateUsers = "no";

      # Needed to create the wg interface and manage routes inside the
      # namespace. systemd-nspawn is documented to grant this with
      # --private-network already; stated explicitly so it does not depend on
      # that behaviour.
      additionalCapabilities = ["CAP_NET_ADMIN"];

      bindMounts =
        {
          # isReadOnly defaults to TRUE, hence it being spelled out on the
          # writable mount below.
          ${wgKeyPath} = {
            hostPath = config.sops.secrets."mullvad-wg-key".path;
            isReadOnly = true;
          };
          # Deliberately not under /run: nspawn gives the container its own
          # tmpfs there. mountPoint defaults to the attribute name and hostPath
          # defaults to the same path, so this line is the whole mount.
          ${downloadsDir}.isReadOnly = false;
          ${profileDir}.isReadOnly = false;
        }
        # The library directories finished torrents are moved into. They have to
        # be mounted individually rather than mounting ${mediaDir} wholesale, so
        # that anything added under /srv/media later is not silently exposed to
        # the sandbox as well.
        #
        # This is the one place the sandbox reaches beyond its own scratch space:
        # it can write AND delete inside these three. That is the cost of having
        # completed downloads file themselves away with no manual step.
        // lib.genAttrs (lib.attrValues categories) (_: {isReadOnly = false;});

      config = _: {
        system.stateVersion = "26.05";

        networking = {
          # No IPv6 address and no IPv6 default route, so v6 traffic has
          # nowhere to go rather than somewhere unencrypted.
          enableIPv6 = false;

          # Containers default useHostResolvConf to true, which would resolve
          # through the host (outside the tunnel) and hand every lookup to
          # Pi-hole's upstreams. Mullvad's internal resolver is reachable only
          # via the tunnel, so DNS cannot leak and cannot resolve at all if
          # the tunnel is down -- the intended behaviour.
          useHostResolvConf = false;
          nameservers = ["10.64.0.1"];

          # Local names still resolve, without consulting Pi-hole: point them
          # at the host across the veth. Caddy is listening there on 443 and
          # host-routes by name, so these reach the real services AND the
          # wildcard certificate validates, because the name matches.
          hosts.${hostAddress} = [
            "home.jenningsliamd.me"
            "files.jenningsliamd.me"
            "jellyfin.jenningsliamd.me"
            "paperless.jenningsliamd.me"
          ];

          # Only Caddy (from hostAddress) ever connects here.
          firewall.allowedTCPPorts = [sandboxPort];

          wireguard.interfaces.mullvad = {
            ips = [address4];
            privateKeyFile = wgKeyPath;
            # We install the default route ourselves below, so the kill switch
            # and the endpoint exception stay in one place.
            allowedIPsAsRoutes = false;

            peers = [
              {
                publicKey = serverPublicKey;
                allowedIPs = ["0.0.0.0/0"];
                inherit endpoint;
                persistentKeepalive = 25;
              }
            ];

            postSetup = ''
              ${ip} -4 route add default dev mullvad
            '';

            postShutdown = ''
              ${ip} -4 route del default dev mullvad || true
            '';
          };
        };

        # The kill switch, and the reason it is a separate unit rather than
        # part of wireguard's postSetup: nixpkgs' container-init script runs
        # BEFORE systemd inside the container and unconditionally installs
        # `default via <hostAddress>`. Left alone, that is unrestricted egress
        # through the host whenever the tunnel is down -- exactly what this is
        # supposed to prevent. So drop it and lay down the blackhole,
        # independently of whether wireguard ever succeeds.
        #
        # The route therefore exists from container-init until this unit runs.
        # That window is not zero, but nothing is listening or dialling out in
        # it, and any service added below is ordered after the tunnel anyway.
        # Trying to get ahead of it with network-pre.target invites an
        # ordering cycle, which systemd resolves by silently dropping a
        # dependency -- worse than a short window.
        systemd.services = {
          sandbox-killswitch = {
            description = "Replace the container's host default route with a blackhole";
            wantedBy = ["multi-user.target"];
            before = ["wireguard-mullvad.service"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              ${ip} -4 route del default via ${hostAddress} || true
              ${ip} -4 route replace blackhole default metric 1000
            '';
            # Removing the blackhole on stop would reopen the leak, so it is
            # left in place for the lifetime of the container.
          };

          # The route to the endpoint has to exist before wireguard starts
          # handshaking, and must not disappear when the tunnel flaps.
          sandbox-endpoint-route = {
            description = "Route the WireGuard endpoint via the host veth";
            wantedBy = ["multi-user.target"];
            after = ["sandbox-killswitch.service"];
            before = ["wireguard-mullvad.service"];
            requires = ["sandbox-killswitch.service"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              ${ip} -4 route replace ${endpointAddress}/32 via ${hostAddress} dev eth0
            '';
          };

          # Ordering for the sandboxed service declared below. Never run it
          # outside the tunnel: `after` keeps it from starting while the
          # interface and its default route are still missing, and `requires`
          # takes it down with the wireguard unit rather than leaving it
          # running against a blackhole.
          qbittorrent = {
            after = ["wireguard-mullvad.service"];
            requires = ["wireguard-mullvad.service"];
            # Pick up edits to the category list without needing a reboot.
            # (The upstream module already triggers on qBittorrent.conf.)
            restartTriggers = [categoriesFile];
          };

          # categories.json is not part of qBittorrent.conf, so the upstream
          # module does not manage it. It cannot be installed via the module's
          # ExecStartPre either -- that option is set to a single string there,
          # and adding a second definition would collide rather than append.
          # Hence a tiny oneshot ordered before the service.
          #
          # Like qBittorrent.conf, this overwrites on every start: categories
          # added or re-pointed in the WebUI revert at the next restart, so the
          # `categories` attrset above is the source of truth. Existing
          # torrents already assigned to a category are unaffected -- their
          # category name lives in the resume data, and only the name-to-path
          # mapping is restated here.
          qbittorrent-categories = {
            description = "Install qBittorrent's declarative category list";
            before = ["qbittorrent.service"];
            requiredBy = ["qbittorrent.service"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            # -D creates the parent directories, so this does not depend on
            # the module's own tmpfiles rules having run first. Group-readable
            # only, matching the 0600 the profile's other config gets, and
            # owned by the service user so qBittorrent can rewrite it while
            # running.
            script = ''
              ${pkgs.coreutils}/bin/install -Dm600 -o sandbox -g media \
                ${categoriesFile} ${profileDir}/qBittorrent/config/categories.json
            '';
          };
        };

        # Matches the host's group numerically (NOT by name -- only the GID
        # crosses the bind mount) so setgid-inherited files are readable by
        # Jellyfin and copyparty on the other side.
        users.groups = {
          media.gid = mediaGid;
          sandbox.gid = 2000;
        };

        # Pinned uid so ownership of files on the host side is stable and
        # recognisable rather than whatever the container happened to allocate.
        users.users.sandbox = {
          isSystemUser = true;
          uid = 2000;
          group = "sandbox";
          extraGroups = ["media"];
        };

        services.qbittorrent = {
          enable = true;

          # `media` is the PRIMARY group, not a supplementary one, and that is
          # load-bearing: the upstream unit sets PrivateUsers=true, which maps
          # only the unit's own uid and gid into its user namespace and turns
          # every supplementary group into the overflow gid. As the primary
          # group it stays mapped, so writes into the setgid 2770 downloads
          # directory are permitted and land as group `media` -- readable by
          # Jellyfin and copyparty on the host side.
          #
          # Both names are already declared above, which also stops the
          # upstream module from creating its own: it only defines the user and
          # group when they are left at the default "qbittorrent".
          user = "sandbox";
          group = "media";

          inherit profileDir;

          # Caddy proxies sandbox.jenningsliamd.me to this port over the veth.
          webuiPort = sandboxPort;
          torrentingPort = torrentPort;
          # networking.firewall above already opens sandboxPort, and opening
          # torrentPort would achieve nothing without port forwarding.
          openFirewall = false;

          # A non-empty serverConfig makes the unit install this file over
          # ${profileDir}/qBittorrent/config/qBittorrent.conf on every start,
          # so anything changed in the WebUI's *settings* pages is reverted at
          # the next restart -- change it here instead. Torrents themselves are
          # unaffected: they live in the profile's resume data, not this file.
          serverConfig = {
            # Without this qbittorrent-nox waits on stdin for someone to accept
            # the legal notice and the unit hangs at start.
            LegalNotice.Accepted = true;

            Preferences.WebUI = {
              # Caddy connects from ${hostAddress} across the veth, so binding
              # to localhost would make the WebUI unreachable.
              Address = "*";
              Username = "liam";
              # A salted PBKDF2-HMAC-SHA512 digest: 16-byte salt, 100k
              # iterations, 64-byte output, both halves base64 and joined by a
              # colon. Generate with `just qbt-hash`, which prompts twice so a
              # typo cannot slip through, and confirm an existing one with
              # `just qbt-check`. Regenerating from the same password gives a
              # different digest every time -- the salt is random, and it is
              # stored in the first half of the value, which is how checking
              # works at all. A digest rather than the password, but it does
              # land world-readable in the Nix store; move it to sops if that
              # matters. Do NOT change it from the WebUI: see the serverConfig
              # note above.
              Password_PBKDF2 = "@ByteArray(WVMsdDa/A1Pz9Gx6SOBrRQ==:ttexLTgXvustvRxcf0vNBTUSLYVQX5Xa+fm2wxsmPk7zloqazEXakUQWbAheZsMoq8tsMeXyoXe4/JVPKPOVDA==)";
              # Log and rate-limit by real client address rather than seeing
              # every request come from ${hostAddress}, trusting only Caddy to
              # have set X-Forwarded-For.
              ReverseProxySupportEnabled = true;
              TrustedReverseProxiesList = hostAddress;
            };

            BitTorrent.Session = {
              # Where an UNCATEGORISED torrent ends up. Categorised ones go to
              # their category's save path instead (see categories above).
              DefaultSavePath = downloadsDir;

              # Download into scratch and only move the finished files to the
              # destination, rather than writing into the library as they go.
              # Two reasons: Jellyfin's scanner would otherwise pick up
              # half-written files as broken entries, and a failed or deleted
              # torrent leaves nothing behind in the library.
              #
              # qBittorrent does the move itself on completion and updates its
              # resume data, so seeding continues from the new location --
              # which is what makes this hands-off, with no mover script.
              # Both keys verified against qbittorrent-nox 5.2.2, which
              # reports them back as temp_path_enabled / temp_path.
              TempPathEnabled = true;
              TempPath = incompleteDir;
              # Strictly redundant -- the namespace has no non-tunnel route to
              # use -- but it makes libtorrent refuse to bind anything except
              # the tunnel, so a mistake here surfaces as "no peers" instead of
              # as traffic on the wrong interface. Both keys verified against
              # qbittorrent-nox 5.2.2: they are what the API reports back as
              # current_network_interface.
              Interface = "mullvad";
              InterfaceName = "mullvad";
            };
          };
        };

        # ADDING ANOTHER SERVICE
        #
        # Declare it here like any NixOS service, following qbittorrent above:
        #   - have it listen on 0.0.0.0 (Caddy arrives over the veth, so
        #     localhost is not reachable), and give it a port of its own plus a
        #     vhost in caddy.nix -- sandboxPort is taken
        #   - run it as the `sandbox` user with `media` as its primary group so
        #     writes to ${downloadsDir} are permitted and correctly grouped
        #   - add the same after/requires pair on wireguard-mullvad.service
      };
    };
  };
}
