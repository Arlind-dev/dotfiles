{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.git.enable = mkEnableOption "Enable Git configuration";

  config = mkIf config.myModules.git.enable {
    programs.git = {
      enable = true;
      userName = "Arlind Sulejmani";
      userEmail = "arlind@sulej.ch";
    };
  };
}
