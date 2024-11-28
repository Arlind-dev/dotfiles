{ config, pkgs, lib, ... }:

let
  enableUtilities = config.MyNixOS.packages.enableUtilities or false;
in
{
  environment.systemPackages = lib.optionals enableUtilities (with pkgs; [
    tree
    unzip
    ripgrep
    htop
    fastfetch
    wget
    tcpdump
    bat
    jq
  ]);
}
