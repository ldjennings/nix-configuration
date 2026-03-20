# flake/nfs.nix
# NFS server support.
_: {
  flake.nixosModules.nfs = _: {
    services = {
      rpcbind.enable = true;
      nfs.server.enable = true;
    };
  };
}
