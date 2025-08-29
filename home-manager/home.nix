{ inputs, lib, config, pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./git.nix
  ];

  nixpkgs = {
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages
    ];
    config.allowUnfree = true;
  };

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
}
