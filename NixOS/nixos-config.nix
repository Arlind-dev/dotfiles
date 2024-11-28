{ config, pkgs, ... }:

{
  MyNixOS = {
    virtualization = {
      enableDocker = true;
      enableDockerDesktop = false; # only works if you have Docker Desktop installed
      enablePodman = false; # Enable either Docker or Podman, I wouldn't enable both / includes docker and docker compose alias
      enableK3s = false;
      enableHelm = false; # Enable Helm (can only be true if K3s is enabled)
    };

    packages = {
      enableUtilities = true;
      enableDatabaseClients = false;
      enableDevelopmentTools = true;
      enableDesktopEnvironment = false;
    };
  };
}
