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

    # deploy-rs lives here, not in the main flake (which only builds configs).
    # Follow configs/nixpkgs so it builds against our cached 26.05 -- deploy-rs's
    # own pinned nixpkgs is old enough that its Rust crate fetcher hits the dead
    # crates.io download URL (403).
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "configs/nixpkgs";
    };
  };

  outputs = {
    self,
    configs,
    deploy-rs,
  }: {
    deploy.nodes.minifridge = {
      # mDNS name (avahi) instead of a DHCP-assigned IP, which isn't stable.
      hostname = "minifridge.local";
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

    # Re-export the pinned deploy-rs CLI so `nix run .#deploy-rs` uses the same
    # version as the activate lib above -- no global `deploy` binary needed.
    inherit (deploy-rs) packages;
  };
}
