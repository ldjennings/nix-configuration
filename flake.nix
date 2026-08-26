{
  description = "my crappy config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri package comes from nixpkgs (binary-cached); this flake is only
    # used for its home-manager settings DSL
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deliberately NOT following our nixpkgs -- keeping their lock means
    # builds hit noctalia.cachix.org instead of compiling quickshell
    noctalia.url = "github:noctalia-dev/noctalia";

    stylix.url = "github:danth/stylix/release-26.05";
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
