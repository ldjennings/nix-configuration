# newModules/hosts/brick/user-configuration.nix
# User account definition and home-manager wiring for brick.
{ self, inputs, ... }: {
  flake.nixosModules.brickUser = { pkgs, config, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    users.mutableUsers = true;
    users.users.${config.host.username} = {
      isNormalUser = true;
      description = config.host.gitUsername;
      extraGroups = [
        "adbusers"
        "docker"
        "libvirtd"
        "lp"
        "networkmanager"
        "scanner"
        "wheel"
      ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };

    nix.settings.allowed-users = [ config.host.username ];

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = false;
      backupFileExtension = "backup";
      extraSpecialArgs = { 
        inherit inputs;
        # needs to be passed in as a module argument
        hostConfig = config.host;
        # legacy args -- remove as you migrate each module
        username = config.host.username;
        host = config.host.hostname;
        profile = "brick";
      };
      users."liam" = {
        imports = [ 
          self.modules.homeManager.brickHome 
          ./../../../modules/home 
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