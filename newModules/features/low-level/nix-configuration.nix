# Flake-parts module for Nix configuration.
# Sets recommended defaults for performance and reliability,
# enables flakes and nix-command, and configures nh for
# convenient NixOS rebuilds with automatic store cleanup.
#
# Usage:
#   Add self.nixosModules.nixConfiguration to your host's modules list.
#   Requires host.flakeDirectory to be set in your host module:
#
#   host.flakeDirectory = "/home/liam/nix-configuration";
{ ... }: {
  flake.nixosModules.nixConfiguration = { config, lib, pkgs, self, ... }: {
    # imports = [ self.nixosModules.hostConfig ];
    # imports = [ "${self}/custom-nix-code/host-config.nix" ];

    nix.settings = {
      # see https://jackson.dev/post/nix-reasonable-defaults/
      # Fail faster on unresponsive substituters
      connect-timeout = 5;
      # Trigger garbage collection when free space drops below 128MB
      min-free = 128000000;
      # Stop garbage collection once 1GB is free
      max-free = 1000000000;
      # Fall back to building from source if a substituter fails
      fallback = true;
      # Larger download buffer for faster fetches on good connections
      download-buffer-size = 250000000;
      # Deduplicate identical files in the nix store automatically
      auto-optimise-store = true;
      # Suppress warnings about uncommitted changes in flakes
      warn-dirty = false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Hyprland binary cache -- avoids rebuilding Hyprland from source
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    # nh -- convenient wrapper around nixos-rebuild with better output
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        # Keep store paths from the last 7 days and at least 5 generations
        extraArgs = "--keep-since 7d --keep 5";
      };
      flake = config.host.flakeDirectory;
    };

    environment.systemPackages = with pkgs; [
      nix-output-monitor # prettier nix build output
      nvd                # diff tool for NixOS generations
    ];
  };
}