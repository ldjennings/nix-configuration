# newModules/home/helix.nix
_: {
  flake.modules.homeManager.helix = {pkgs, ...}: {
    programs.helix = {
      enable = true;
      package = pkgs.helix;
      defaultEditor = true;

      settings = {
        # theme = "base16_transparent";

        editor = {
          line-number = "relative";
          cursorline = true;
          color-modes = true;
          scroll-lines = 3;
          mouse = false;

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          indent-guides = {
            render = true;
            character = "╎";
          };

          statusline = {
            left = ["mode" "spinner" "file-name" "file-modification-indicator"];
            center = ["version-control"];
            right = ["diagnostics" "selections" "position" "file-encoding"];
          };

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };

          whitespace.render = {
            space = "none";
            tab = "all";
            newline = "none";
          };
        };

        keys.normal = {
          "C-h" = "jump_view_left";
          "C-l" = "jump_view_right";
          "C-k" = "jump_view_up";
          "C-j" = "jump_view_down";
          "space"."f" = "file_picker";
          "space"."b" = "buffer_picker";
        };
      };

      languages = {
        language-server = {
          nixd = {
            command = "${pkgs.nixd}/bin/nixd";
            config.nixd = {
              nixpkgs.expr = "import <nixpkgs> {}";
              options.nixos.expr = "(builtins.getFlake \"/home/liam/nix-configuration\").nixosConfigurations.brick.options";
            };
          };

          bash-language-server = {
            command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
            args = ["start"];
          };

          marksman = {
            command = "${pkgs.marksman}/bin/marksman";
            args = ["server"];
          };
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            language-servers = ["nixd"];
            formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          }
          {
            name = "bash";
            auto-format = true;
            language-servers = ["bash-language-server"];
          }
          {
            name = "markdown";
            language-servers = ["marksman"];
          }
        ];
      };
    };
  };
}
