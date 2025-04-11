{ config, pkgs, ... }:

{
  users.users.root = {
    shell = pkgs.zsh;
  };

  home-manager.users.root = {
    home.stateVersion = "24.11";
  };
}
