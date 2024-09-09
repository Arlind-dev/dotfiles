{ config, pkgs, lib, ... }:

let
  enableK3s = config.MyNixOS.virtualization.enableK3s or false;
in
{
  services.k3s = {
    enable = enableK3s;
    role = "server";
    extraFlags = lib.optionals enableK3s [
      "--write-kubeconfig-mode=0644"
    ];
  };
}
