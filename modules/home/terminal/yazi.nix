# newModules/home/yazi.nix
# Terminal file manager with image previews, git integration, and fuzzy jumping.
_: {
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      enable = true;
      # Changes shell directory when you quit yazi -- lets you navigate
      # the filesystem in yazi and land in the right place in your shell
      enableZshIntegration = true;

      settings = {
        mgr = {
          sort_dir_first = true; # directories before files
          show_symlink = true; # show symlink targets -- important on NixOS
          show_hidden = false; # toggle with . at runtime
        };

        opener = {
          # Open files in $EDITOR (helix)
          edit = [
            {
              run = ''$EDITOR "$@"'';
              desc = "$EDITOR";
              block = true; # wait for editor to close before returning
              for = "unix";
            }
          ];

          # Open media in mpv, with mediainfo fallback for inspection
          play = [
            {
              run = ''mpv --force-window "$@"'';
              orphan = true; # don't block yazi while mpv is open
              for = "unix";
            }
            {
              run = ''mediainfo "$1"; echo "Press enter to exit"; read _'';
              block = true;
              desc = "Show media info";
              for = "unix";
            }
          ];
        };
      };

      keymap = {
        mgr.prepend_keymap = [
          # {
          #   # Open lazygit in the current directory
          #   on = [ "g" "i" ];
          #   run = "plugin lazygit";
          #   desc = "Open lazygit";
          # }
          {
            # Smart enter: opens files directly, enters directories
            # Replaces the default 'l' which only enters directories
            on = "l";
            run = "plugin smart-enter";
            desc = "Enter dir or open file";
          }
          {
            on = ["y" "c"];
            run = "shell 'wl-copy < \"$0\"'";
            desc = "Copy file contents to clipboard";
          }
        ];
      };

      theme = {
        status = {
          # Powerline-style separators for the status bar
          sep_left = [
            "░▒▓"
            "▓▒░"
          ];
          sep_right = [
            "░▒▓"
            "▓▒░"
          ];
        };
        confirm = {
          # Color-coded yes/no buttons in confirmation dialogs
          btn_yes = {
            bg = "green";
            fg = "black";
            bold = true;
          };
          btn_no = {
            bg = "red";
            fg = "black";
            bold = true;
          };
        };
      };

      plugins = {
        # inherit (pkgs.yaziPlugins) lazygit;
        inherit (pkgs.yaziPlugins) full-border;
        inherit (pkgs.yaziPlugins) git;
        inherit (pkgs.yaziPlugins) smart-enter;
      };

      initLua = ''
        require("full-border"):setup()
        require("git"):setup()
        require("smart-enter"):setup {
          open_multi = true,
        }
      '';
    };
  };
}
