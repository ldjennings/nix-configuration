# hosts/brick/home.nix or a shared newModules/home/xdg.nix
{ ... }: {
  flake.modules.homeManager.xdg = { ... }: {
    xdg = {
      enable = true;
      mime.enable = true;

      # Create standard user directories (Downloads, Pictures, etc.)
      userDirs = {
        enable = true;
        createDirectories = true;
      };

      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html"                = "firefox.desktop";
          "text/plain"               = "org.gnome.gedit.desktop";
          "application/pdf"          = "firefox.desktop";
          "inode/directory"          = "kitty.desktop";
          "image/bmp"                = "nsxiv.desktop";
          "image/gif"                = "nsxiv.desktop";
          "image/jpeg"               = "nsxiv.desktop";
          "image/jpg"                = "nsxiv.desktop";
          "image/png"                = "nsxiv.desktop";
          "image/tiff"               = "nsxiv.desktop";
          "image/webp"               = "nsxiv.desktop";
          "image/x-bmp"              = "nsxiv.desktop";
          "image/x-portable-anymap"  = "nsxiv.desktop";
          "image/x-portable-bitmap"  = "nsxiv.desktop";
          "image/x-portable-graymap" = "nsxiv.desktop";
          "image/x-tga"              = "nsxiv.desktop";
          "image/x-xpixmap"          = "nsxiv.desktop";
          "image/svg+xml"            = "nsxiv.desktop";
          "x-scheme-handler/http"    = "firefox.desktop";
          "x-scheme-handler/https"   = "firefox.desktop";
          "x-scheme-handler/about"   = "firefox.desktop";
          "x-scheme-handler/unknown" = "firefox.desktop";
          "video/mp4"                = "vlc.desktop";
          "audio/mpeg"               = "vlc.desktop";
          "audio/mp3"                = "vlc.desktop";
          "audio/wav"                = "vlc.desktop";
        };
      };
    };
  };
}