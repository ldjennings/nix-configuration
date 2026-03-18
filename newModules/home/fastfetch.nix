# newModules/home/fastfetch.nix
{ ... }: {
  flake.modules.homeManager.fastfetch = { ... }: {
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