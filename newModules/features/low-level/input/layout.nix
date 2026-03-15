# Keyboard input configuration.
# Remaps capslock to delete, capslock+ctrl to capslock,
# and sets Colemak as the default keyboard layout via XKB.
{
  flake.nixosModules.layout = { ... }: {
    # Capslock remapping at the kernel level via keyd
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings = {
          # Capslock acts as delete in normal use
          main.capslock = "delete";
          # Capslock+ctrl restores capslock behaviour
          control.capslock = "capslock";
        };
      };
    };

    # Colemak layout via XKB -- applied at the Wayland/X11 level
    # so fcitx5 and other input methods are aware of it
    services.xserver.xkb = {
      layout = "us";
      variant = "colemak";
    };

    # Colemak layout for TTY/console
    console.useXkbConfig = true; 
  };
}