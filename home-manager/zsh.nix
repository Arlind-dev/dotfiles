{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      d = "docker";
      d-c = "docker compose";
      ff = "fastfetch";
      rebuild = "sudo nixos-rebuild switch --flake ~/nix-config#nixos";
      update = "nix flake update --flake ~/nix-config";
      clean = "nix-collect-garbage -d";
      rebuild-all = "update && rebuild && clean";
      nix-repo-ssh = "git -C ~/nix-config remote set-url origin git@github.com:Arlind-dev/dotfiles.git";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "alanpeabody";
    };
  };
}
