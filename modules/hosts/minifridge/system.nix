{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.minifridge = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      username = "liam";
      host = "minifridge";
      profile = "minifridge";
    };
    modules = [
      inputs.disko.nixosModules.disko
      inputs.nixos-hardware.nixosModules.common-cpu-intel # microcode + kvm-intel
      inputs.nixos-hardware.nixosModules.common-pc-ssd # periodic fstrim

      self.nixosModules.hostConfig # always first -- defines host.* options
      self.nixosModules.minifridgeDisk
      self.nixosModules.minifridgeHardware
      self.nixosModules.hostMinifridge
      self.nixosModules.minifridgeUser
    ];
  };

  flake.nixosModules.hostMinifridge = {
    config,
    lib,
    ...
  }: {
    imports = with self.nixosModules; [
      # core
      bootConfig
      nixConfiguration
      locale
      security
      defaultEditor
      cliUtils

      # services
      avahi # advertise minifridge.local over mDNS

      # hardware -- QuickSync for Jellyfin/ffmpeg transcoding
      intelQuickSync
    ];

    networking = {
      hostName = config.host.hostname;
      # Headless: plain DHCP via scripted networking, no NetworkManager.
      useDHCP = lib.mkDefault true;
      firewall = {
        enable = true;
        allowedTCPPorts = [22];
      };
    };

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    # Compressed RAM swap instead of a disk swap partition.
    zramSwap.enable = true;

    # Shared media storage on the /srv btrfs disk. Service accounts (Jellyfin,
    # *arr, etc.) get added to the "media" group; setgid (2775) makes new files
    # inherit the group so downloads and library stay mutually accessible and
    # hardlinkable within the one subvolume.
    users.groups.media = {};
    systemd.tmpfiles.rules = [
      "d /srv/media 2775 root media - "
      "d /srv/downloads 2775 root media - "
    ];

    host = {
      username = "liam";
      flakeDirectory = "/home/liam/nix-configuration";
      hostname = "minifridge";
      gitUsername = "Liam Jennings";
      gitEmail = "72767491+ldjennings@users.noreply.github.com";
      # Headless server -- keyboard options are unused but required by hostConfig.
      keyboard = {
        layout = "us";
        variant = "";
        options = "";
      };
    };

    system.stateVersion = "26.05"; # Do not change! (matches first install)
  };
}
