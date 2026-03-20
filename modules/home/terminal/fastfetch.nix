# newModules/home/fastfetch.nix
_: {
  flake.modules.homeManager.fastfetch = _: {
    programs.fastfetch = {
      enable = true;
      settings = {
        modules = [
          "os"
          "kernel"
          "packages"
          "shell"
          "wm"
          "terminal"
          "host"
          "cpu"
          "gpu"
          "memory"
          "disk"
          "uptime"
        ];
      };
    };
  };
}
