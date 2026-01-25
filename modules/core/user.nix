{
  pkgs,
  inputs,
  username,
  host,
  profile,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) gitUsername;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = false;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit
        inputs
        username
        host
        profile
        ;
    };
    users.${username} = {
      imports = [ ./../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "25.05";
      };
      xresources.properties = {
        "Nsxiv.window.background" = "#0d0e15";
        "Nsxiv.window.foreground" = "#e9e9f4";

        "Nsxiv.bar.background" = "#0d0e15";
        "Nsxiv.bar.foreground" = "#e9e9f4";
      };
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "firefox.desktop";
          "text/plain" = "org.gnome.gedit.desktop";
          "application/pdf" = "firefox.desktop";

          "inode/directory" = "kitty.desktop";


          "image/bmp"  = "nsxiv.desktop";
          "image/gif"= "nsxiv.desktop";
          "image/jpeg"= "nsxiv.desktop";
          "image/jpg"= "nsxiv.desktop";
          "image/png"= "nsxiv.desktop";
          "image/tiff"= "nsxiv.desktop";
          "image/webp"= "nsxiv.desktop";
          "image/x-bmp"= "nsxiv.desktop";
          "image/x-portable-anymap"= "nsxiv.desktop";
          "image/x-portable-bitmap"= "nsxiv.desktop";
          "image/x-portable-graymap"= "nsxiv.desktop";
          "image/x-tga"= "nsxiv.desktop";
          "image/x-xpixmap"= "nsxiv.desktop";
          "image/svg+xml" = "nsxiv.desktop";

          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
          "x-scheme-handler/about" = "firefox.desktop";
          "x-scheme-handler/unknown" = "firefox.desktop";

          "video/mp4" = "vlc.desktop";
          "audio/mpeg" = "vlc.desktop";
          "audio/mp3" = "vlc.desktop";
          "audio/wav" = "vlc.desktop";
        };
      };
    };
  };
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
    extraGroups = [
      "adbusers"
      "docker"
      "libvirtd"
      "lp"
      "networkmanager"
      "scanner"
      "wheel"
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };
  nix.settings.allowed-users = [ "${username}" ];
}
