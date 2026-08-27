{
  description = "reproducible deployments for nix-configuration";

  # Kept separate from the main flake on purpose: the main flake's job is to
  # *build* nixosConfigurations. deploy-rs wants to live inside the flake output
  # fixpoint (deploy.nodes + generated checks) while also reading back out of it
  # (nixosConfigurations), which entangles the two into one recursive fixpoint.
  # A distinct flake is a distinct fixpoint, so no recursion.
  inputs = {
    # committed state of the parent repo (git+file only sees committed changes,
    # so run `nix flake update configs` here after committing config changes)
    configs.url = "git+file:..";
    deploy-rs.follows = "configs/deploy-rs";
  };

  outputs = {
    self,
    configs,
    deploy-rs,
  }: {
    deploy.nodes.minifridge = {
      hostname = "192.168.1.106";
      profiles.system = {
        user = "root";
        sshUser = "liam";
        path =
          deploy-rs.lib.x86_64-linux.activate.nixos
          configs.nixosConfigurations.minifridge;
      };
    };

    # deploy-rs's own sanity checks, surfaced through `nix flake check` here
    checks =
      builtins.mapAttrs
      (system: deployLib: deployLib.deployChecks self.deploy)
      deploy-rs.lib;
  };
}
