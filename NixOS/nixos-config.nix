{ config, pkgs, ... }:

{
  MyNixOS = {
    virtualization = {
      enableDocker = false; #(rootless)
      enablePodman = false; # Enable either Docker or Podman, I wouldn't enable both / includes docker and docker compose alias
      enableK3s = false;
      enableHelm = false; # Enable Helm (can only be true if K3s is enabled)
    };

    packages = {
      enableUtilities = true;
      enableDatabaseClients = false;
      enableDevelopmentTools = false;
      enableDesktopEnvironment = false;
    };
  };
}