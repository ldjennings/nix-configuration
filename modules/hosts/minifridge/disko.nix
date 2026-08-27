# Declarative disk layout for minifridge, applied by disko at install time
# (via nixos-anywhere). Two NVMe drives:
#   - main:  Samsung 970 EVO Plus 500GB -> OS (ESP + btrfs root subvolumes)
#   - media: Samsung MZVL2512 512GB     -> media/data (btrfs at /srv/media)
# Swap is handled by zram (see system.nix), so there is no swap partition.
#
# Devices are pinned by /dev/disk/by-id/* so they always map to the same
# physical drive regardless of nvme0/nvme1 enumeration order. BOTH drives are
# erased on install.
_: {
  flake.nixosModules.minifridgeDisk = _: {
    disko.devices.disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S58SNM0R525780P";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                };
              };
            };
          };
        };
      };

      media = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NF0WC27420";
        content = {
          type = "gpt";
          partitions = {
            srv = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                # Single subvolume mounted at /srv. media/ and downloads/ are
                # plain subdirectories under it (created via systemd.tmpfiles in
                # system.nix) so the *arr apps can hardlink between them --
                # hardlinks cannot cross btrfs subvolume boundaries.
                subvolumes = {
                  "@srv" = {
                    mountpoint = "/srv";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
