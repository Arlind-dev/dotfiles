{ config, pkgs, ... }:
{
  networking.hostName = "nixos-wsl";

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  programs.nix-ld.enable = true;
}
