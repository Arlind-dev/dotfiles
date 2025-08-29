{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Arlind Sulejmani";
    userEmail = "arlind@sulej.ch";
  };
}
