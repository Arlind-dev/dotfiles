{ config, pkgs, lib, ... }:

let
  enableDocker = config.MyNixOS.virtualization.enableDocker or false;
in
{
  virtualisation.docker = {
    enable = enableDocker;
  };

  environment.systemPackages = lib.optionals enableDocker (with pkgs; [
    docker-compose
    ctop
  ]);
}
