# speaker-tuning from nixos-hardware: https://github.com/NixOS/nixos-hardware/blob/master/framework/13-inch/common/audio.nix
# replaces "builtin analog stereo" with "framework speakers"
# note that the previous device (analog stereo) should be at 100% before applying this change

{
  flake.nixosModules.hostBrick = {
    ...
  }: {

    hardware.framework.laptop13.audioEnhancement = {
      enable = true;
      rawDeviceName = "alsa_output.pci-0000_00_1f.3.analog-stereo";
      
      # Hides the raw speaker device to avoid volume conflicts (default: true)
      hideRawDevice = true;
    };
  };
}