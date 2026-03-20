# newModules/home/eza.nix
_: {
  flake.modules.homeManager.eza = _: {
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