# Storage and filesystem services
_: {
  flake.nixosModules.mountServices = _: {
    services = {
      # Virtual filesystem -- network shares, MTP devices (phones), trash
      gvfs.enable = true;

      # Disk automounting
      udisks2.enable = true;

      # Drive health monitoring
      smartd = {
        enable = true;
        autodetect = true;
      };
    };
  };
}
