{ config, pkgs, lib, ... }:

let
  enableK3s = config.MyNixOS.virtualization.enableK3s or false;
in
{
  programs.nix-ld = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      "d" = "docker $*";
      "d-c" = "docker compose $*";
      "ff" = "fastfetch";
      "rebuild" = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix/NixOS";
      "update" = "nix flake update --flake ~/.dotfiles/nix/NixOS";
      "sync-dotfiles" = "git -C ~/.dotfiles/nix pull";
      "clean" = "nix-collect-garbage -d";
      "rebuild-all" = "sync-dotfiles && update && rebuild && clean";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "alanpeabody";
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  programs.git = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.variables = {
    EDITOR = "nvim";
    GPG_TTY = "$(tty)";
  } // lib.mkIf enableK3s {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  system.autoUpgrade.enable = true;
}
