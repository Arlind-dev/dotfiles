{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    enableMouse = true;
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
}
