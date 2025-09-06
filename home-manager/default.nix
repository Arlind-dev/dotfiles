{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ../modules/home-manager
    ./pc.nix
    ./server.nix
    ./wsl.nix
  ];

  nixpkgs = {
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages
      inputs.self.overlays.neovim-nightly
    ];
    config.allowUnfree = true;
  };

  home = {
    username = "arlind";
    homeDirectory = "/home/arlind";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";

  environment.variables = {
    EDITOR = "nvim";
    GPG_TTY = "$(tty)";
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
}
