{ config, pkgs, ... }:

{
  users.users.nixos = {
    isNormalUser = true;
    home = "/home/nixos";
    shell = pkgs.zsh;
    extraGroups = [ "docker" ];
  };

  home-manager.users.nixos = {
    home.stateVersion = "24.05";
  };
}
