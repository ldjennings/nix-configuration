# Flake-parts module for gaming support.
# Includes Steam with Proton, Gamescope, GameMode, and various
# launchers for GOG, Epic, and other game stores.
{ ... }: {
  flake.nixosModules.gaming = { pkgs, ... }: {
    programs = {
      # GameMode -- temporarily boosts performance when games are running
      gamemode.enable = true;

      gamescope = {
        enable = true;
        # capSysNice allows gamescope to renice processes for better performance
        capSysNice = true;
        args = [
          "--rt"             # realtime scheduling
          "--expose-wayland" # expose Wayland display to games
        ];
      };

      steam = {
        enable = true;

        # Open firewall ports for Steam Remote Play
        # remotePlay.openFirewall = true;

        # Keep dedicated server ports closed unless needed
        dedicatedServer.openFirewall = false;

        # Launch Steam in Gamescope session
        gamescopeSession.enable = true;

        # Proton-GE -- community Proton build with broader game compatibility
        extraCompatPackages = with pkgs; [ proton-ge-bin ];

        # Protontricks -- fix compatibility issues in specific Proton games
        protontricks.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      lutris          # multi-platform game launcher (GOG, Battle.net, etc.)
      # heroic          # GOG and Epic Games launcher
      bottles         # Wine prefix management GUI
      steam-run       # run games/apps in Steam's runtime environment
      # prismlauncher   # Minecraft launcher with mod support
      mangohud        # performance overlay for games (FPS, CPU, GPU usage)
    ];
  };
}