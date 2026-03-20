{
  inputs,
  self,
  ...
}: {

  # systems = [ "x86_64-linux" ];

  flake.nixosConfigurations.brick = inputs.nixpkgs.lib.nixosSystem {

    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      username = "liam";
      host = "brick";
      profile = "brick";
    };
    modules = [
      # "${self}/profiles/intel"
      self.nixosModules.hostConfig  # always first -- defines host.* options
      self.nixosModules.hostBrick
      self.nixosModules.brickUser
      inputs.nixos-hardware.nixosModules.framework-12th-gen-intel  
    ];
  };

  flake.nixosModules.hostBrick = {pkgs, config, ...}: {
    imports = with self.nixosModules; [
      # core
      appImageSupport
      bootConfig
      defaultEditor
      fonts
      locale
      nixConfiguration
      security

      # desktop
      periphreals
      input
      pinyinInput

      desktopPrograms
      gaming
      stylix
      thunar

      # hardware
      intelGPU
      mountServices
      printing

      # programs
      cliUtils
      desktopUtils
      sysUtils

      # services
      bluetooth
      greetd
      mullvad
      networking
      nfs
      pipewire
      powerSave
      virtualization

      niri
    ];

    boot = {
      kernelPackages = pkgs.linuxPackages_zen;
      kernelModules = ["coretemp" "cpuid" "v4l2loopback"];
      extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    };

    host ={
      username = "liam";
      flakeDirectory = "/home/liam/nix-configuration";
      hostname = "brick";
      gitUsername = "Liam Jennings";
      gitEmail = "72767491+ldjennings@users.noreply.github.com";
    };

    system.stateVersion = "25.05"; # Do not change!
  };
}

