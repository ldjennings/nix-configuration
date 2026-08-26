{
  inputs,
  self,
  ...
}: {
  # systems = [ "x86_64-linux" ];

  flake.nixosConfigurations.minifridge = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    # specialArgs = {
    #   inherit inputs;
    #   username = "liam";
    #   host = "minifridge";
    #   profile = "minifridge";
    # };
    modules = [
      # "${self}/profiles/intel"

    ];
  };
}