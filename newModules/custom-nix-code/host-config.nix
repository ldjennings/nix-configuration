# custom-nix-code/host-config.nix
# Flake-parts module defining shared per-host configuration options.
# Exposes host.username, host.hostname, and host.flakeDirectory.
#
# Add self.nixosModules.hostConfig to your host's modules list:
#
#   modules = [
#     self.nixosModules.hostConfig
#     self.nixosModules.networking
#     # ...
#   ];
#
# Then set the options in your host module:
#
#   host = {
#     username = "liam";
#     hostname = "brick";
#     flakeDirectory = "/home/liam/nix-configuration";
#   };
{ self, ... }: {
  flake.nixosModules.hostConfig = { lib, ... }:
  let
    inherit (self.lib) requiredOption;
  in
  {
    options.host = {
      username = requiredOption {
        name = "host.username";
        type = lib.types.str;
        usedFor = "user account, login session, home directory, group membership";
        suggestion = "\"liam\"";
        description = "Primary user account for this machine.";
        example = "liam";
      };

      hostname = requiredOption {
        name = "host.hostname";
        type = lib.types.str;
        usedFor = "system hostname and network identity";
        suggestion = "\"brick\"";
        description = "Machine hostname.";
        example = "brick";
      };

      flakeDirectory = requiredOption {
        name = "host.flakeDirectory";
        type = lib.types.str;
        usedFor = "nh rebuild path";
        suggestion = "\"/home/liam/nix-configuration\"";
        description = "Path to the NixOS flake directory, used by nh for rebuilds.";
        example = "/home/liam/nix-configuration";
      };
    };
  };
}