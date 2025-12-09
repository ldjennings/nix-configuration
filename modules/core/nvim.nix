{
  pkgs,
  username,
  ...
}: {

programs.neovim = {
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
};

}