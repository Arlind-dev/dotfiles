{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.tmux.enable = mkEnableOption "Enable Tmux configuration";

  config = mkIf config.myModules.tmux.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      extraConfig = ''
        set -g default-terminal "tmux-256color"
        set -g mouse on
        set -g @plugin 'tmux-plugins/tpm'
        set -g @plugin 'tmux-plugins/tmux-sensible'
        set -g @plugin 'tmux-plugins/tmux-resurrect'
        set -g @plugin 'tmux-plugins/tmux-continuum'
        set -g @continuum-restore 'on'
        set -g @continuum-save 'on'
        '';
    };
  };
}
