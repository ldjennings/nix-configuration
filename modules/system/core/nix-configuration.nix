# Flake-parts module for Nix configuration.
# Sets recommended defaults for performance and reliability,
# enables flakes and nix-command, configures nh for convenient
# NixOS rebuilds, and provides Nix development tooling.
#
# Usage:
#   Add self.nixosModules.nixConfiguration to your host's modules list.
#   Requires host.flakeDirectory to be set in your host module:
#
#   host.flakeDirectory = "/home/liam/nix-configuration";
{inputs, ...}: {
  flake.nixosModules.nixConfiguration = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      # pre-built nix-index database -- avoids slow local generation
      inputs.nix-index-database.nixosModules.nix-index
    ];

    nixpkgs.config.allowUnfree = true;

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
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    # nh -- convenient wrapper around nixos-rebuild with better output
    programs = {
      nh = {
        enable = true;
        clean = {
          enable = true;
          # Keep store paths from the last 7 days and at least 5 generations
          extraArgs = "--keep-since 7d --keep 5";
        };
        flake = config.host.flakeDirectory;
      };

      # run unpatched dynamic binaries on NixOS
      # useful for pre-built toolchains and embedded development
      nix-ld.enable = true;

      # comma -- run any nixpkgs binary without installing it
      # e.g. `, cowsay hello` runs cowsay from nixpkgs
      nix-index-database.comma.enable = true;

      # direnv -- auto-load nix shells when entering project directories
      direnv = {
        enable = true;
        silent = false;
        loadInNixShell = true;
        nix-direnv.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      nix-output-monitor # prettier nix build output
      nvd # diff between NixOS generations
      nixd # Nix language server for editor support
      statix # Nix linter
      alejandra # Nix formatter
      manix # Nix documentation searcher
      nix-inspect # TUI for inspecting Nix store
    ];
  };
}
