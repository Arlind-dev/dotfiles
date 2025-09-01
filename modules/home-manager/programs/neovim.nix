{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.neovim.enable = mkEnableOption "Enable Neovim configuration";

  config = mkIf config.myModules.neovim.enable {
    programs.neovim = {
      enable = true;
      package = pkgs.neovim;

      # Optional: Add some basic configuration
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # You can add plugins, extraConfig, etc. here
      # plugins = with pkgs.vimPlugins; [
      #   # Add your desired plugins
      # ];

      # extraConfig = ''
      #   " Add your vim configuration here
      # '';
    };
  };
}
