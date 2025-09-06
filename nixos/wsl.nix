{ config, pkgs, ... }:
{
  networking.hostName = "nixos-wsl";

  wsl.enable = true;
  wsl.defaultUser = "arlind";

  programs.nix-ld.enable = true;

  imports = [
    ../modules/nixos/default.nix
  ];

  virtualisation.docker = {
    enable = true;
  };

  myModules = {
    utilities.enable = true;
  };
}
