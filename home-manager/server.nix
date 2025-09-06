{ inputs, lib, config, pkgs, ... }:

{
  myModules = {
    git.enable = true;
    zsh.enable = true;
    neovim.enable = true;
    tmux.enable = true;
  };
}
