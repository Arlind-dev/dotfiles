{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tree
    unzip
    ripgrep
    htop
    fastfetch
    wget
    tcpdump
    bat
    jq
    zip
    gh
    dig
  ];
}
