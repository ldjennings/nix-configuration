# system/programs/sysutils.nix
# Programs and packages requiring elevated privileges, udev rules,
# or direct hardware access. Purely userspace tools belong in
# cli-utils.nix or home/programs/ instead.
_: {
  flake.nixosModules.sysUtils = {pkgs, ...}: {
    programs = {
      # Needs setuid for raw socket access
      mtr.enable = true;
      # Needs udev rules and adbusers group
      adb.enable = true;
      # GPG agent with SSH support
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    environment.systemPackages = with pkgs; [
      # Hardware inspection
      lm_sensors # temperature monitoring
      lshw # hardware inventory
      pciutils # lspci
      usbutils # lsusb

      # Display/GPU
      brightnessctl # needs udev rules

      # Kernel/driver utilities
      v4l-utils # video4linux for OBS virtual camera
    ];
  };
}
