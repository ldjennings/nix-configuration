# hosts/brick/home.nix
# Brick-specific home-manager configuration.
# Host-agnostic HM modules live in newModules/home/ and are imported below.
{ self, ... }:
{
  flake.modules.homeManager.brickHome =
    { ... }:
    {
      # nixpkgs.config.allowUnfree = true;

      imports = with self.modules.homeManager; [
        # shared HM modules will go here as you migrate them
        # e.g. hyprland, waybar, zsh, kitty, git, etc.
        niri
        # gammastep
        bat
        btop
        eza
        fastfetch
        formula
        fzf
        git
        helix
        htop
        hyprland
        hmFind
        kitty
        lsp
        rofi
        swappy
        swaync
        tempPackages
        theming
        waylandEnv
        wlogout
        xdg
        yazi
        zsh
      ];

      xresources.properties = {
        "Nsxiv.window.background" = "#0d0e15";
        "Nsxiv.window.foreground" = "#e9e9f4";
        "Nsxiv.bar.background" = "#0d0e15";
        "Nsxiv.bar.foreground" = "#e9e9f4";
      };

      # xdg.userDirs = {
      #   enable = true;
      #   createDirectories = true;
      # };

      # xdg.mimeApps = {
      #   enable = true;
      #   defaultApplications = {
      #     "text/html"                  = "firefox.desktop";
      #     "text/plain"                 = "org.gnome.gedit.desktop";
      #     "application/pdf"            = "firefox.desktop";
      #     "inode/directory"            = "kitty.desktop";
      #     "image/bmp"                  = "nsxiv.desktop";
      #     "image/gif"                  = "nsxiv.desktop";
      #     "image/jpeg"                 = "nsxiv.desktop";
      #     "image/jpg"                  = "nsxiv.desktop";
      #     "image/png"                  = "nsxiv.desktop";
      #     "image/tiff"                 = "nsxiv.desktop";
      #     "image/webp"                 = "nsxiv.desktop";
      #     "image/x-bmp"                = "nsxiv.desktop";
      #     "image/x-portable-anymap"    = "nsxiv.desktop";
      #     "image/x-portable-bitmap"    = "nsxiv.desktop";
      #     "image/x-portable-graymap"   = "nsxiv.desktop";
      #     "image/x-tga"                = "nsxiv.desktop";
      #     "image/x-xpixmap"            = "nsxiv.desktop";
      #     "image/svg+xml"              = "nsxiv.desktop";
      #     "x-scheme-handler/http"      = "firefox.desktop";
      #     "x-scheme-handler/https"     = "firefox.desktop";
      #     "x-scheme-handler/about"     = "firefox.desktop";
      #     "x-scheme-handler/unknown"   = "firefox.desktop";
      #     "video/mp4"                  = "vlc.desktop";
      #     "audio/mpeg"                 = "vlc.desktop";
      #     "audio/mp3"                  = "vlc.desktop";
      #     "audio/wav"                  = "vlc.desktop";
      #   };
      # };
    };
}
