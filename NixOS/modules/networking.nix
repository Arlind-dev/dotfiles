{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 2222 3390 6443 ];
    allowedUDPPorts = [];
  };
}
