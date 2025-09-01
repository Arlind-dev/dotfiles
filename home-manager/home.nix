{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ../modules/home-manager
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
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";

  myModules = {
    git.enable = true;
    zsh.enable = true;
    neovim.enable = true;
  };
}
