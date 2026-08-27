# Media server for minifridge: Jellyfin (streaming, hardware transcode via
# Intel QuickSync) + copyparty (browser-based upload/file management).
# Libraries live on the dedicated /srv media disk (see disko.nix); the host
# must also provide intelQuickSync for hardware transcoding.
_: {
  flake.nixosModules.minifridgeMedia = {pkgs, ...}: let
    mediaDir = "/srv/media";
    mediaGroup = "media";
  in {
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
      # Single admin account. The password is read at service start from this
      # runtime path (never enters the Nix store) -- create it before first
      # boot, readable by the copyparty user, e.g. (pipe via stdin so it
      # survives sudo closing inherited fds):
      #   printf pw | sudo install -Dm600 -o copyparty /dev/stdin /etc/copyparty/admin.pw
      accounts.admin.passwordFile = "/etc/copyparty/admin.pw";
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

    networking.firewall.allowedTCPPorts = [3210];
  };
}
