# Flake-parts module for firmware update manager.
# run:
#   fwupdmgr refresh
#   fwupdmgr get-updates
#   fwupdmgr update
# to update the firmware
_: {
  flake.nixosModules.firmwareUpdates = _: {
    services.fwupd.enable = true;
  };
}
