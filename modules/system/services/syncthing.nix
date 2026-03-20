# Flake-parts module for Syncthing file synchronization.
# Syncthing keeps folders in sync across devices peer-to-peer,
# without a central server. Similar to Dropbox but self-hosted.
# import in your host module if you want to sync files between 
# multiple devices.
_: {
  flake.nixosModules.syncthing = { config, ... }: {
    services.syncthing = {
      enable = true;
      user = config.host.username;
      dataDir = "/home/${config.host.username}";
      configDir = "/home/${config.host.username}/.config/syncthing";
    };
  };
}