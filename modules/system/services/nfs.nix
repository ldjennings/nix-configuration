# flake/nfs.nix
# NFS server support.
{ ... }: {
  flake.nixosModules.nfs = { ... }: {
    services = {
      rpcbind.enable = true;
      nfs.server.enable = true;
    };
  };
}