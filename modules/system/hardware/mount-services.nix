# Storage and filesystem services
_: {
  flake.nixosModules.mountServices = _: {
    # Virtual filesystem -- network shares, MTP devices (phones), trash
    services.gvfs.enable = true;

    # Disk automounting
    services.udisks2.enable = true;

    # Drive health monitoring
    services.smartd = {
      enable = true;
      autodetect = true;
    };
  };
}