# system/core/boot-config.nix
# Generic boot configuration suitable for most modern x86 EFI systems.
# Host-specific settings (kernel, modules, hardware tweaks) belong in
# the host's own module instead.
_: {
  flake.nixosModules.bootConfig = _: {
    boot = {
      # Suppress most kernel messages during boot
      consoleLogLevel = 3;
      kernelParams = ["quiet"];

      # Plymouth boot splash
      plymouth.enable = true;

      # systemd-based initrd -- faster boot, better hardware support
      initrd.systemd.enable = true;

      # EFI bootloader
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      # NTFS support for external drives and dual-boot Windows partitions
      supportedFilesystems.ntfs = true;
    };
  };
}
