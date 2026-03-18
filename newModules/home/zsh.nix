# newModules/home/zsh.nix
{ ... }: {
  flake.modules.homeManager.zsh = { lib, hostConfig, ... }: {
    # fallback
    programs.bash.enable = true; 


    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
          "pattern"
          "regexp"
          "root"
          "line"
        ];
      };
      historySubstringSearch.enable = true;
      history = {
        ignoreDups = true;
        save = 10000;
        size = 10000;
      };

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "sudo"
          "colored-man-pages"
        ];
      };

      initContent = lib.mkOrder 1000 ''
        # vim-style word navigation
        bindkey "\eh" backward-word
        bindkey "\ej" down-line-or-history
        bindkey "\ek" up-line-or-history
        bindkey "\el" forward-word
      '';

      shellAliases = {
        # editors
        v   = "hx";
        sv  = "sudo hx";

        # nix
        fr  = "nh os switch --hostname ${hostConfig.hostname}";
        fu  = "nh os switch --hostname ${hostConfig.hostname} --update";
        ft  = "nh os test --hostname ${hostConfig.hostname}";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";

        # replacements
        cat  = "bat";
        man  = "batman";

        # eza
        ls   = "eza --icons --group-directories-first -1";
        ll   = "eza --icons -lh --group-directories-first -1 --no-user --long";
        la   = "eza --icons -lah --group-directories-first -1";
        tree = "eza --icons --tree --group-directories-first";

        # git
        gc  = "git commit";
        gs  = "git status -sb";
        gap = "git add -p";
        gd  = "git diff";
        gds = "git diff --staged";
        gl  = "git log --oneline --decorate --graph";

        # misc
        c = "clear";
      };
    };
  };
}