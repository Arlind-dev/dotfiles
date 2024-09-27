{ config, pkgs, lib, ... }:

let
  enableDocker = config.MyNixOS.virtualization.enableDocker or false;
in
{
  virtualisation.docker = {
    enable = enableDocker;
    rootless = {
      enable = enableDocker;
      setSocketVariable = enableDocker;
    };
  };

  wsl = {
    docker-desktop.enable = true;
  };

  environment.systemPackages = lib.optionals enableDocker (with pkgs; [
    docker-compose
    ctop
  ]);
}
