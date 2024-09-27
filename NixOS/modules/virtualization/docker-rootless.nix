{ config, pkgs, lib, ... }:

let
  enableDockerRootless = config.MyNixOS.virtualization.enableDockerRootless or false;
in
{
  virtualisation.docker = {
    enable = enableDockerRootless;
    rootless = {
      enable = enableDockerRootless;
      setSocketVariable = enableDockerRootless;
    };
  };

  environment.systemPackages = lib.optionals enableDockerRootless (with pkgs; [
    docker-compose
    ctop
  ]);
}
