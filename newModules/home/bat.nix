# newModules/home/bat.nix
{ ... }: {
  flake.modules.homeManager.bat = { pkgs, ... }: {
    programs.bat = {
      enable = true;
      config.pager = "less -FR";
      extraPackages = with pkgs.bat-extras; [
        batman
        batpipe
        batgrep
      ];
    };
  };
}