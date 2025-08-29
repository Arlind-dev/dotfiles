{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs = {
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages
    ];
    config.allowUnfree = true;
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "";
      download-buffer-size = 524288000;
    };

    channel.enable = true;

    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    gc = {
      automatic = true;
      dates = "daily";
    };
  };

  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    initialPassword = "correcthorsebatterystaple";
    openssh.authorizedKeys.keys = [ ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.nixos = import ../home-manager/home.nix;
  };

  programs.zsh.enable = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings.LANG = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Zurich";

  system.stateVersion = "25.05";
}
