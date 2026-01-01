{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) gitUsername gitEmail;
in
{
  programs.git = {
    enable = true;
    settings = {
      user.email = "${gitEmail}";
      user.name = "${gitUsername}";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
