{ config, pkgs, ... }:

{
  imports = [
    # Packages
    ./modules/packages/default.nix
    ./modules/packages/utilities.nix
    ./modules/packages/database-clients.nix
    ./modules/packages/development-tools.nix
    ./modules/packages/desktop-applications.nix
    # Users
    ./modules/users/nixos.nix
    ./modules/users/root.nix
    # Virtualization
    ./modules/virtualization/docker.nix
    ./modules/virtualization/podman.nix
    ./modules/virtualization/k3s.nix
    ./modules/virtualization/helm.nix
    # General
    ./modules/networking.nix
    ./modules/system-services.nix
    ./modules/programs.nix
    ./modules/mynixos-options.nix
    # MyNixOS specific configurations
    ./nixos-config.nix
  ];

  system.stateVersion = "24.05";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANG = "en_US.UTF-8";
  };
  time.timeZone = "Europe/Zurich";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.dates = "daily";

  fileSystems."/home/nixos" = {
    device = "/mnt/c/wsl/nixos/home.vhdx";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  wsl = {
    enable = true;
    defaultUser = "nixos";
    nativeSystemd = true;
  };
}
