{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.brick = inputs.nixpkgs.lib.nixosSystem {

    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      username = "liam";
      host = "brick";
      profile = "brick";
    };
    modules = [
      ../../
      self.nixosModules.hostBrick
      inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
      
    ];
  };

  flake.nixosModules.hostBrick = {pkgs, ...}: {
    
    
  };
}
