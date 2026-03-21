# Flake-parts module for text editors.
# Neovim is kept as a minimal backup editor -- no custom configuration,
# just the base install with vi/vim aliases for muscle memory compatibility.
# Primary editor is Helix (configured separately).
_: {
  flake.nixosModules.defaultEditor = {...}: {
    programs.neovim = {
      enable = true;
      # set as default editor for programs that invoke $EDITOR
      defaultEditor = true;
      # aliases for muscle memory
      viAlias = true;
      vimAlias = true;
    };
  };
}
