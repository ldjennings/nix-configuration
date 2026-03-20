# newModules/home/desktop/waylandEnv.nix
# Generic Wayland environment variables.
# Works under both Hyprland and Niri -- compositor-specific variables
# (XDG_CURRENT_DESKTOP etc.) are set by greetd at session start.
_: {
  flake.modules.homeManager.waylandEnv = _: {
    home.sessionVariables = {
      # Enable native Wayland rendering for Electron apps (VSCode, Discord, etc.)
      NIXOS_OZONE_WL = "1";

      # Tell apps they're running under Wayland
      XDG_SESSION_TYPE = "wayland";

      # Qt: use Wayland backend, fall back to XCB/X11 if needed
      QT_QPA_PLATFORM = "wayland;xcb";

      # Prevent Qt apps from drawing their own window decorations
      # (compositor handles this instead, avoids double titlebars)
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      # Force SDL games to use XWayland rather than native Wayland
      # Fixes Steam game launch failures on Wayland
      SDL_VIDEODRIVER = "x11";

      # Enable native Wayland rendering in Firefox
      MOZ_ENABLE_WAYLAND = "1";

      # Tell Hyprland's Aquamarine backend which GPU devices to use
      # Ignored by Niri -- harmless to set regardless of compositor
      AQ_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1";

      # Keep GTK and Qt scaling at 1x -- compositor handles scaling
      # Prevents double-scaling on HiDPI displays
      GDK_SCALE     = "1";
      QT_SCALE_FACTOR = "1";
    };
  };
}