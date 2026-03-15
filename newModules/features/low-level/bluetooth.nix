{ ... }: {
  flake.nixosModules.bluetooth = { ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;  # automatically power on bluetooth at boot
    };
    services.blueman.enable = true; # Bluetooth Support
  };
}