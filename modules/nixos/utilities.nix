{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.utilities.enable = mkEnableOption "Enable basic utilities";

  config = mkIf config.myModules.utilities.enable {
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
  };
}
