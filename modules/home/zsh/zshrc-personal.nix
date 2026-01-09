{ pkgs, ... }:
{
  home.packages = with pkgs; [ zsh ];

  home.file."./.zshrc-personal".text = ''

    # This file allows you to define your own aliases, functions, etc
    # below are just some examples of what you can use this file for

      #!/usr/bin/env zsh
      # Set defaults
      #
      #export EDITOR="nvim"
      #export VISUAL="nvim"

      alias c="clear"

      # git aliases
      alias gc='git commit -v'
      alias gs='git status -sb'
      alias gap='git add -p'
      alias gd='git diff'
      alias gds='git diff --staged'
      alias gl='git log --oneline --decorate --graph'
     

  '';
}
