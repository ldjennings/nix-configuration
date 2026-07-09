# newModules/hosts/brick/user-configuration.nix
# User account definition and home-manager wiring for brick.
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.brickUser = {
    pkgs,
    config,
    ...
  }: {
    imports = [inputs.home-manager.nixosModules.home-manager];

    users.mutableUsers = true;
    users.users.${config.host.username} = {
      isNormalUser = true;
      initialPassword = "nixos";
      description = config.host.gitUsername;
      extraGroups = [
        # adbusers removed: gone along with programs.adb in 26.05; systemd's
        # uaccess rules grant the logged-in user access to adb devices
        # libvirtd removed: virtualisation.libvirtd is disabled, so the group
        # doesn't exist -- re-add alongside libvirtd.enable = true
        "lp"
        "networkmanager"
        "scanner"
        "wheel"
      ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };

    nix.settings.allowed-users = [config.host.username];

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "backup";

      extraSpecialArgs = {
        inherit inputs;
        # needs to be passed in as a module argument
        hostConfig = config.host;
      };

      users."liam" = {
        imports = [
          self.modules.homeManager.brickHome
        ];
        home = {
          username = "liam";
          homeDirectory = "/home/liam";
          stateVersion = "25.05";
        };
      };
    };
  };
}
