# newModules/home/eza.nix
{ ... }: {
  flake.modules.homeManager.eza = { ... }: {
    programs.eza = {
      enable = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--no-quotes"
        "--git-ignore"
        "--icons=always"
      ];
    };
  };
}