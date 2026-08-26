{
  inputs,
  self,
  ...
}: {
  # systems = [ "x86_64-linux" ];

  deploy.nodes.minifridge = {
    hostname = "192.168.1.106";
    profiles.system = {
      path = self.nixosConfigurations.minifridge;
    };
  };
}