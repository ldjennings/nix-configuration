{
  inputs,
  self,
  ...
}: {

  systems = [ "x86_64-linux" ];

  flake.nixosConfigurations.brick = inputs.nixpkgs.lib.nixosSystem {

    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      username = "liam";
      host = "brick";
      profile = "brick";
    };
    modules = [
      "${self}/profiles/intel"
      self.nixosModules.hostBrick
      inputs.nixos-hardware.nixosModules.framework-12th-gen-intel  
    ];
  };

  flake.nixosModules.hostBrick = {pkgs, config, ...}: {
    imports = with self.nixosModules; [
      appImageSupport
      networking
      virtualization
      gpuIntel
      printing
      layout
      gamingMouse
      pinyinInput
      nixConfiguration
      locale
    ];
    boot = {
      consoleLogLevel = 3;
      kernelPackages = pkgs.linuxPackages_zen;
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      initrd.systemd.enable = true;

      supportedFilesystems.ntfs = true;

      kernelParams = ["quiet"];
      kernelModules = ["coretemp" "cpuid" "v4l2loopback"];
      # To support the v4l2loopback to enable  obs/screen sharing
      extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

      # raises maximum number of memory map instances a process can have, intended to be used with games
      kernel.sysctl = {
        "vm.max_map_count" = 2147483642;
      };

    };

    boot.plymouth.enable = true;

    network-config.hostName = "brick";
    nix-config.flakeDirectory = "/home/liam/nix-configuration";

    # auto mounting of usbs
    services.udisks2.enable = true;



    # TODO: move this to desktop once I make that file  
    services.xserver.enable = false;

    system.stateVersion = "25.05"; # Do not change!
  };
}
