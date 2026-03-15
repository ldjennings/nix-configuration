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
    imports = [
      self.nixosModules.appImageSupport
      self.nixosModules.networking
      self.nixosModules.virtualization
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

    networking.hostName = "brick";
      
  };
}
