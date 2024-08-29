{ config, pkgs, ... }:

{
  imports = [
    <nixos-wsl/modules>
    <home-manager/nixos>
  ];

  system.stateVersion = "24.05";

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.dates = "daily";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANG = "en_US.UTF-8";
  };
  time.timeZone = "Europe/Zurich";

  users.users.nixos = {
    isNormalUser = true;
    home = "/home/nixos";
    shell = pkgs.zsh;
    extraGroups = [ "docker" ];
  };

  environment.systemPackages = with pkgs; [
    gcc
    tree
    unzip
    ripgrep
  ];
  environment.variables.EDITOR = "nvim";

  virtualisation.docker.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git"];
      theme = "alanpeabody";
    };
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

  home-manager.users.nixos = {
    home.stateVersion = "24.05";
  };
}
