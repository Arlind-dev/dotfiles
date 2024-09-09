{ config, pkgs, lib, ... }:

let
  enablePodman = config.MyNixOS.virtualization.enablePodman or false;
in
{
  virtualisation.podman = {
    enable = enablePodman;
    defaultNetwork.settings.dns_enabled = enablePodman;
    dockerCompat = enablePodman;
  };

  environment.systemPackages = lib.optionals enablePodman (with pkgs; [
    podman-compose
    podman-tui
    ctop
  ]);
}
