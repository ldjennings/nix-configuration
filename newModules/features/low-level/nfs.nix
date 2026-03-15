# flake/nfs.nix
# NFS server support.
# TODO: add to networking folder
{ ... }: {
  flake.nixosModules.nfs = { ... }: {
    services = {
      rpcbind.enable = true;
      nfs.server.enable = true;
    };
  };
}