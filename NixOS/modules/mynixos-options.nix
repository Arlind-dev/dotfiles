{ lib, ... }:

{
  options.MyNixOS = {
    virtualization = {
      enableDocker = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable Docker support.";
      };

      enablePodman = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable Podman support.";
      };

      enableK3s = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable K3s support.";
      };

      enableHelm = lib.mkOption {
        type = lib.types.bool;
        default = lib.mkDefault false;
        description = "Enable Helm support (requires K3s).";
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
        default = false;
        description = "Whether to enable the desktop environment and related services like Plasma, SDDM, and XRDP.";
      };
    };
  };

  config = {
    MyNixOS.virtualization.enableDocker = lib.mkDefault false;
    MyNixOS.virtualization.enablePodman = lib.mkDefault false;
    MyNixOS.virtualization.enableK3s = lib.mkDefault false;
    MyNixOS.virtualization.enableHelm = lib.mkDefault false;

    MyNixOS.packages.enableUtilities = lib.mkDefault true;
    MyNixOS.packages.enableDatabaseClients = lib.mkDefault false;
    MyNixOS.packages.enableDevelopmentTools = lib.mkDefault false;
    MyNixOS.packages.enableDesktopEnvironment = lib.mkDefault false;
  };
}
