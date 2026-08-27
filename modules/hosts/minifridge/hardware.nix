# Hardware/boot details for minifridge (HP EliteDesk 800 G4/G5, Intel
# i5-8500T, Coffee Lake). Filesystems are declared via disko (see disko.nix),
# so no fileSystems are hand-written here.
#
# Intel microcode + kvm-intel come from nixos-hardware's common-cpu-intel, and
# periodic SSD TRIM from common-pc-ssd (both wired in system.nix), so they are
# not repeated here.
_: {
  flake.nixosModules.minifridgeHardware = {lib, ...}: {
    boot = {
      # NVMe root on a standard Intel desktop chipset
      initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
      initrd.kernelModules = [];
      extraModulePackages = [];
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # Non-free-but-legal firmware for NIC/GPU that a hardware scan may miss.
    hardware.enableRedistributableFirmware = true;

    # Intel thermal management daemon -- avoids throttling/overheating.
    services.thermald.enable = true;
  };
}
