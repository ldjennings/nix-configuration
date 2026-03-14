{
  description = "ZaneyOS";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-25.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # treefmt-nix = {
    #   url = "github:numtide/treefmt-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      host = "brick";
      profile = "brick";
      username = "liam";
      # forAllSystems = nixpkgs.lib.genAttrs system;
    in
    {
      nixosConfigurations = {
        brick = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit username;
            inherit host;
            inherit profile;
          };
          modules = [
            ./profiles/intel
            inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
          ];
        };
      };
    };
}
