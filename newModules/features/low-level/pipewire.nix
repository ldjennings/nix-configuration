{ ... }: {
  flake.nixosModules.pipewire = { ... }: {    
    # requires pipewire to actually work
    services.pipewire = {
      enable = true;
      alsa.support32Bit = true;
      alsa.enable = true;
      pulse.enable = true;
    };

      security.rtkit.enable = true;
  };
}