# newModules/home/desktop/noctalia.nix
# Noctalia desktop shell (quickshell-based) -- bar, launcher, notifications,
# lock screen, wallpaper and OSDs in one process. Used with niri, which
# starts it via spawn-at-startup.
{inputs, ...}: {
  flake.modules.homeManager.noctalia = {
    imports = [inputs.noctalia.homeModules.default];

    programs.noctalia = {
      enable = true;
      # The systemd unit binds to graphical-session.target and would also
      # start inside Hyprland sessions, fighting waybar/swaync. Enable this
      # (and drop the niri spawn-at-startup entry) once Hyprland is gone.
      # systemd.enable = true;
    };
  };
}
