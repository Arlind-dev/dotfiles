{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { };
in
{
  imports = [
    <nixos-wsl/modules>
    <home-manager/nixos>
  ];


  wsl.enable = true;
  wsl.defaultUser = "nixos";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    gcc
    git
    tree
    unzip
    ripgrep
    unstable.neovim
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANG = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Zurich";

  users.users.nixos = {
    isNormalUser = true;
    home = "/home/nixos";
    shell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
    shellAliases = {
      neovim = "nvim";
      vim = "nvim";
      vi = "nvim";
      vimdiff = "nvim -d";
    };
  };

  home-manager.users.nixos = {
    home.stateVersion = "24.05";
    programs.zsh.enable = true;
    programs.git.enable = true;
  };

  nix.gc.automatic = true;
  nix.gc.dates = "daily";

  system.stateVersion = "24.05";
}
