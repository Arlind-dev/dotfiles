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
  ];

  MyNixOS.virtualization = {
    enableDocker = false; #(rootless)
    enablePodman = false; # Enable either Docker or Podman, I wouldn't enable both / includes docker and docker compose alias
    enableK3s = false;
    enableHelm = false; # Enable Helm (can only be true if K3s is enabled)
  };

  MyNixOS.packages = {
    enableUtilities = true;
    enableDatabaseClients = false;
    enableDevelopmentTools = false;
    enableDesktopEnvironment = false;
  };

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
