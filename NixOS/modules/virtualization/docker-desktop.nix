{ config, pkgs, lib, ... }:

let
  enableDockerDesktop = config.MyNixOS.virtualization.enableDockerDesktop or false;
in
{
  wsl = {
    docker-desktop.enable = enableDockerDesktop;
  };
}
