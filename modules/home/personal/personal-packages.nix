_: {
  flake.modules.homeManager.personalPackages = {pkgs, ...}: {
    home.packages = with pkgs; [
      typst
    ];
  };
}
