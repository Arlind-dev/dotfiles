{ lib, ... }:

{
  options.MyNixOS = {
    virtualization = {
      enableDocker = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable Docker support.";
      };

      enableDockerDesktop = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable Docker Desktop integration (requires Docker Desktop to be installed).";
      };

      enablePodman = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable Podman support. Choose either Docker or Podman to avoid conflicts.";
      };

      enableK3s = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable K3s (lightweight Kubernetes) support.";
      };

      enableHelm = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable Helm support (requires K3s to be enabled).";
      };
    };

    packages = {
      enableUtilities = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault true;
        description = "Enable general utility packages.";
      };

      enableDatabaseClients = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable database clients (MySQL, PostgreSQL, SQLite).";
      };

      enableDevelopmentTools = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable development tools (gcc, gnumake, cmake, etc.).";
      };

      enableDesktopEnvironment = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable the desktop environment and related services like Plasma, SDDM, and XRDP.";
      };
    };
  };

  config = {
    MyNixOS.virtualization.enableDocker = lib.mkDefault false;
    MyNixOS.virtualization.enableDockerDesktop = lib.mkDefault false;
    MyNixOS.virtualization.enablePodman = lib.mkDefault false;
    MyNixOS.virtualization.enableK3s = lib.mkDefault false;
    MyNixOS.virtualization.enableHelm = lib.mkDefault false;

    MyNixOS.packages.enableUtilities = lib.mkDefault true;
    MyNixOS.packages.enableDatabaseClients = lib.mkDefault false;
    MyNixOS.packages.enableDevelopmentTools = lib.mkDefault false;
    MyNixOS.packages.enableDesktopEnvironment = lib.mkDefault false;
  };
}
