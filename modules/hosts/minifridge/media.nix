# Media server for minifridge: Jellyfin (streaming, hardware transcode via
# Intel QuickSync) + copyparty (browser-based upload/file management).
# Libraries live on the dedicated /srv media disk (see disko.nix); the host
# must also provide intelQuickSync for hardware transcoding.
_: {
  flake.nixosModules.minifridgeMedia = {
    pkgs,
    lib,
    config,
    ...
  }: let
    mediaDir = "/srv/media";
    mediaGroup = "media";
  in {
    # copyparty reads its admin password from this decrypted secret at start.
    sops.secrets."copyparty-admin".owner = "copyparty";

    users.groups.${mediaGroup} = {
      members = ["jellyfin" "copyparty"];
    };

    # Jellyfin's primary group is `media` (below); it also needs `render` for
    # /dev/dri access to do QuickSync hardware transcoding.
    users.users.jellyfin.extraGroups = ["render"];

    systemd.tmpfiles.rules = [
      "d ${mediaDir}          0750 root      ${mediaGroup} -"
      "d ${mediaDir}/Music    2750 copyparty ${mediaGroup} -"
      "d ${mediaDir}/Movies   2750 copyparty ${mediaGroup} -"
      "d ${mediaDir}/TV       2750 copyparty ${mediaGroup} -"
    ];

    environment.systemPackages = [pkgs.jellyfin-ffmpeg];

    services.jellyfin = {
      enable = true;
      group = mediaGroup;
      openFirewall = true;
    };

    services.copyparty = {
      enable = true;
      group = mediaGroup;
      settings = {
        i = "0.0.0.0";
        p = [3210];
        chmod-f = "640";
        chmod-d = "2750";
      };
      # Single admin account. Password comes from the sops secret, decrypted to
      # /run/secrets at activation and owned by copyparty so the service can
      # read it. Edit with: sops secrets/minifridge.yaml (key copyparty-admin).
      accounts.admin.passwordFile = config.sops.secrets."copyparty-admin".path;
      volumes = {
        # rwmda = read/write/move/delete/admin -- full control for admin only.
        "/Music" = {
          path = "${mediaDir}/Music";
          access.rwmda = ["admin"];
          flags.scan = 60;
        };
        "/Movies" = {
          path = "${mediaDir}/Movies";
          access.rwmda = ["admin"];
          flags.scan = 60;
        };
        "/TV" = {
          path = "${mediaDir}/TV";
          access.rwmda = ["admin"];
          flags.scan = 60;
        };
      };
    };

    # The upstream copyparty module hardens the unit with RestrictSUIDSGID=true
    # and UMask=0077. copyparty feeds chmod-d (2750, setgid) straight into
    # os.mkdir, so creating any upload subfolder trips RestrictSUIDSGID and
    # fails with EPERM -> HTTP 500 ("operation not permitted" on os.mkdir).
    # UMask=0077 would also strip the group-read bit Jellyfin needs. Relax both
    # just for this service so setgid dirs (group=media, group-readable) work.
    systemd.services.copyparty.serviceConfig = {
      RestrictSUIDSGID = lib.mkForce false;
      UMask = lib.mkForce "0027";
    };

    networking.firewall.allowedTCPPorts = [3210];
  };
}
