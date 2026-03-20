# newModules/home/lsp.nix
# Language server installations.
# Configuration for each LSP lives in the relevant editor module.
_: {
  flake.modules.homeManager.lsp = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Nix
      nixd
      nixfmt-rfc-style

      # Bash
      nodePackages.bash-language-server
      shellcheck

      # Markdown
      marksman
    ];
  };
}
