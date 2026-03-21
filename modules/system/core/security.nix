# Flake-parts module for system security configuration.
# Kernel hardening, polkit rules, PAM, coredump disabling,
# and secret management.
# Threat model: personal laptop used for embedded development,
# not a high-value target.
#
# Usage:
#   Add self.nixosModules.security to your host's modules list.
#
# Notable tradeoffs:
#   - ptrace_scope = 1 (not 2) to allow debuggers (gdb, openocd, probe-rs)
#   - unprivileged_userns_clone = 1 to allow Flatpak, Podman, browsers
#   - can module NOT blacklisted to allow SocketCAN/CAN over USB
#   - SSH server disabled (no daemon = no attack surface)
#   - hardened kernel skipped (breaks Flatpak, browsers, containers)
#   - hardened_malloc skipped (breaks Firefox)
_: {
  flake.nixosModules.security = {
    config,
    username,
    ...
  }: {
    # -------------------------------------------------------------------------
    # Kernel security settings
    # -------------------------------------------------------------------------
    security = {
      # Protect kernel image from modification at runtime
      protectKernelImage = true;

      # Force Page Table Isolation -- mitigates Meltdown and some KASLR bypasses
      forcePageTableIsolation = true;

      # User namespaces required for Flatpak, Podman rootless, and browsers
      allowUserNamespaces = true;

      # Only enable unprivileged user namespaces if containers are enabled
      unprivilegedUsernsClone = config.virtualisation.containers.enable;

      polkit = {
        enable = true;
        # Allow users group to reboot/poweroff without root
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if ( subject.isInGroup("users") && (
             action.id == "org.freedesktop.login1.reboot" ||
             action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
             action.id == "org.freedesktop.login1.power-off" ||
             action.id == "org.freedesktop.login1.power-off-multiple-sessions"
            ))
            { return polkit.Result.YES; }
          })
        '';
      };

      # PAM authentication for screen locker
      # update if switching away from swaylock
      pam.services.swaylock = {
        text = "auth include login";
      };

      # Sudoers rules for Framework LED control without password prompt
      # allows scripting LED color changes for battery/status indication
      sudo.extraRules = [
        {
          users = ["${username}"];
          commands = [
            {
              command = "/run/current-system/sw/bin/ectool led power red";
              options = ["NOPASSWD"];
            }
            {
              command = "/run/current-system/sw/bin/ectool led power white";
              options = ["NOPASSWD"];
            }
            {
              command = "/run/current-system/sw/bin/ectool led power amber";
              options = ["NOPASSWD"];
            }
            {
              command = "/run/current-system/sw/bin/ectool led power off";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];

      # Disable coredumps -- prevents sensitive data leakage from crash dumps
      pam.loginLimits = [
        {
          domain = "*";
          type = "-";
          item = "core";
          value = "0";
        }
      ];
    };

    # Disable coredump handling in systemd
    systemd.coredump.enable = false;

    # Disable root account
    users.users.root.hashedPassword = "!";

    # -------------------------------------------------------------------------
    # Kernel sysctl hardening
    # -------------------------------------------------------------------------
    boot.kernel.sysctl = {
      # Filesystem
      "fs.suid_dumpable" = 0;
      "fs.protected_symlinks" = 1;
      "fs.protected_hardlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;

      # Kernel -- prevent pointer/log leaks
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;

      # Restrict eBPF to CAP_BPF capability
      # note: some container runtimes and browser sandboxes rely on this
      "kernel.unprivileged_bpf_disabled" = 1;

      # Prevent use-after-free exploits
      "vm.unprivileged_userfaultfd" = 0;

      # Disable kexec -- prevents booting a different kernel at runtime
      "kernel.kexec_load_disabled" = 1;

      # SysRq -- restrict to secure attention key only
      "kernel.sysrq" = 4;

      # User namespaces -- keep enabled for Flatpak, Podman, browsers, nh
      "kernel.unprivileged_userns_clone" = 1;

      # Restrict performance events to CAP_PERFMON
      # set to 1 if you use perf for profiling
      "kernel.perf_event_paranoid" = 3;

      # Memory
      "kernel.randomize_va_space" = 2;
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;

      # Userspace
      # ptrace scope 1 -- allows debuggers (gdb, openocd, probe-rs) to work
      # scope 2 would require root for all ptrace, breaking embedded debugging
      "kernel.yama.ptrace_scope" = 1;

      # Network -- DoS protection
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;

      # Source validation -- prevents IP spoofing
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;

      # Disable ICMP redirects -- prevents MITM attacks
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;

      # Disable source routing
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.default.accept_source_route" = 0;

      # Disable IP forwarding -- this is a workstation not a router
      "net.ipv4.conf.all.forwarding" = 0;
      "net.ipv6.conf.all.forwarding" = 0;

      # Ignore bogus ICMP errors
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

      # TCP performance
      # TCP Fast Open for both incoming and outgoing connections
      "net.ipv4.tcp_fastopen" = 3;

      # BBR congestion control + CAKE qdisc -- reduces bufferbloat
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
    };

    # -------------------------------------------------------------------------
    # Kernel module blacklist
    # Obscure/unused networking protocols and filesystems
    # CAN is intentionally NOT blacklisted -- needed for SocketCAN/CAN over USB
    # -------------------------------------------------------------------------
    boot.blacklistedKernelModules = [
      # Obscure networking protocols -- not used on a typical desktop
      "dccp" # Datagram Congestion Control Protocol
      "sctp" # Stream Control Transmission Protocol
      "rds" # Reliable Datagram Sockets
      "tipc" # Transparent Inter-Process Communication
      "n-hdlc" # High-level Data Link Control
      "ax25" # Amateur X.25
      "netrom" # NetRom
      "x25" # X.25
      "rose"
      "decnet"
      "econet"
      "af_802154" # IEEE 802.15.4
      "ipx" # Internetwork Packet Exchange
      "appletalk"
      "psnap" # SubnetworkAccess Protocol
      "p8023" # Novell raw IEEE 802.3
      "p8022" # IEEE 802.3
      "atm"
      # Rare/legacy filesystems
      "cramfs"
      "freevxfs"
      "jffs2"
      "hfs"
      "hfsplus"
      "udf"
    ];

    # -------------------------------------------------------------------------
    # Services
    # -------------------------------------------------------------------------

    
    services = {
      # Use dbus-broker -- more resilient to resource exhaustion attacks
      dbus.implementation = "broker";
      
      # Secret and credential storage -- used by many apps even outside GNOME
      gnome.gnome-keyring.enable = true;
    };

    


    # -------------------------------------------------------------------------
    # User groups for embedded development
    # -------------------------------------------------------------------------
    users.users.${username}.extraGroups = [
      "dialout" # serial ports (/dev/ttyUSB*, /dev/ttyACM*) for embedded tools
      "uucp" # alternative serial group
      "plugdev" # USB device access via udev rules
    ];
  };
}
