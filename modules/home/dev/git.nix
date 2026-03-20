# newModules/home/git.nix
_: {
  flake.modules.homeManager.git = {hostConfig, ...}: {
    programs.gh.enable = true;

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = hostConfig.gitUsername;
          email = hostConfig.gitEmail;
        };

        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        # automatically prune deleted remote branches on fetch
        fetch.prune = true;
        # show a diff when writing commit messages
        commit.verbose = true;
        # rebase instead of merge on pull by default
        pull.rebase = true;
        # more readable diff output
        diff.colorMoved = "zebra";
      };
    };
  };
}
