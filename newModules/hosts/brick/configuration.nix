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

    # auto mounting of usbs
    services.udisks2.enable = true;

    # audio enhancements from nixos-hardware: https://github.com/NixOS/nixos-hardware/blob/master/framework/13-inch/common/audio.nix
    # replaces "builtin analog stereo" with "framework speakers"
    # note that the previous device (analog stereo) should be at 100% before applying this change
    hardware.framework.laptop13.audioEnhancement = {
      enable = true;
      rawDeviceName = "alsa_output.pci-0000_00_1f.3.analog-stereo";
      
      # Hides the raw speaker device to avoid volume conflicts (default: true)
      hideRawDevice = true;
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # TODO: move this to desktop once I make that file  
    services.xserver.enable = false;
  };
}
