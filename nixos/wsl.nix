{ config, pkgs, ... }:
{
  networking.hostName = "nixos-wsl";

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  programs.nix-ld.enable = true;

  imports = [
    ../modules/nixos/default.nix
  ];

  virtualisation.docker = {
    enable = enableDocker;
  };

  myModules = {
    utilities.enable = true;
  };
}
