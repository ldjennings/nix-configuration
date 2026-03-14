{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.main = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hostMain
      inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
    ];
  };

  flake.nixosModules.hostMain = {pkgs, ...}: {
    # imports = [
    #   self.nixosModules.base
    #   self.nixosModules.general
    #   self.nixosModules.desktop

    #   self.nixosModules.impermanence

    #   self.nixosModules.discord
    #   self.nixosModules.gimp
    #   self.nixosModules.hyprland
    #   self.nixosModules.telegram
    #   self.nixosModules.youtube-music

    #   self.nixosModules.gaming
    #   self.nixosModules.vr
    #   self.nixosModules.powersave

    #   # disko
    #   inputs.disko.nixosModules.disko
    #   self.diskoConfigurations.hostMain
    # ];


    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;

      supportedFilesystems.ntfs = true;

      kernelParams = ["quiet" "mem_sleep_default=deep"];
      kernelModules = ["coretemp" "cpuid" "v4l2loopback"];
    };

    boot.plymouth.enable = true;

    networking = {
      hostName = "main";
      networkmanager.enable = true;
    };

    virtualisation.libvirtd.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };

    hardware.cpu.amd.updateMicrocode = true;

    services = {
      hardware.openrgb.enable = true;
      flatpak.enable = true;
      udisks2.enable = true;
      printing.enable = true;
    };

    programs.alvr.enable = true;
    programs.alvr.openFirewall = true;



    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    xdg.portal.enable = true;

    hardware.graphics.enable = true;

    networking.firewall.enable = false;
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    services.xserver.videoDrivers = ["amdgpu"];
    boot.initrd.kernelModules = ["amdgpu"];


    # services.create_ap = {
    #   enable = true;
    #   settings = {
    #     INTERNET_IFACE = "enp14s0";
    #     WIFI_IFACE = "wlp15s0";
    #     SSID = "TROJANVIRUS67";
    #     PASSPHRASE = "yuriiyuriiyurii";
    #
    #     FREQ_BAND = "5"; # 5GHz
    #     COUNTRY = "UA";
    #     CHANNEL = "36"; # Channel 36
    #     IEEE80211N = "1"; # WiFi 4
    #     IEEE80211AC = "1"; # WiFi 5
    #     IEEE80211AX = "1"; # WiFi 6 (HE)
    #     HT_CAPAB = "[HT40+]"; # 40MHz
    #   };
    # };
    #
    # # no conflicts
    # networking.networkmanager.unmanaged = ["wlp15s0"];
    # # speed
    # networking.firewall.allowedUDPPorts = [53 67];

    system.stateVersion = "25.05"; # Do not change!
  };
}