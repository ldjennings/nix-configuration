# User account for minifridge. Headless server, so no home-manager/desktop --
# just the liam login used for deploy-rs (ssh in as liam, sudo to root).
_: {
  flake.nixosModules.minifridgeUser = {
    pkgs,
    config,
    ...
  }: {
    users.mutableUsers = true;
    users.users.${config.host.username} = {
      isNormalUser = true;
      initialPassword = "nixos";
      description = config.host.gitUsername;
      extraGroups = ["wheel"];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ0AnEek/p2f3ri1AdexTOz7rbMs/dlwGMgf75u3Cbs liam@brick"
      ];
    };

    # zsh must be enabled system-wide when used as a login shell.
    programs.zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = ["git" "sudo"];
      };
    };

    nix.settings.allowed-users = [config.host.username];

    # deploy-rs activates the system profile as root by sudo-ing from liam;
    # password-less sudo for wheel lets that run non-interactively.
    security.sudo.wheelNeedsPassword = false;
  };
}
