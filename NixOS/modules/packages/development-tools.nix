{ config, pkgs, lib, ... }:

let
  enableDevelopmentTools = config.MyNixOS.packages.enableDevelopmentTools or false;
in
{
  environment.systemPackages = lib.optionals enableDevelopmentTools (with pkgs; [
    gcc
    glibc
    binutils
    gnumake
    cmake
    python3
    python3Packages.pip
    python3Packages.git-filter-repo
    nodejs
    dotnet-sdk_8
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    nodePackages.nodemon
    rustup
    act
  ]);
}
