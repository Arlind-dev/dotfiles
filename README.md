# My NixOS Config

This guide outlines the steps to set up NixOS on Windows Subsystem for Linux (WSL), including importing **my NixOS configuration**.

## Task List

This project isn't finished; it's currently barely usable. It might improve as soon as these things are done:

### High Priority

- Implement dynamic VHDX allocation for the home directory instead of static 5GB.

### Medium Priority

- Integrate dotfiles for common tools such as Zsh, Git, Neovim, Tmux, and others.
- Configure Standalone Home Manager for both the `nixos` and `root` user.

### Low Priority

- Enhance the script by adding additional validation checks to see if virtualization is enabled on your CPU.

## Installing My NixOS on WSL

1. **Run the Setup Script**

   Open PowerShell and run:

   ```PowerShell
   Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Arlind-dev/dotfiles/main/Windows/setup-wsl.ps1").Content
   ```

   The script will check if it is running with administrative privileges and will restart itself with elevated permissions if necessary.

2. **Launch WSL:**

   Simply type:

   ```PowerShell
   wsl
   ```

## Details

### The `setup-wsl.ps1` Script

This script sets up and configures a NixOS environment within WSL2. It performs tasks such as downloading the NixOS image, setting up the disk, cloning **my configuration**, and applying it to the system. Below is an explanation of how the script works and what you need to know.

#### Key Features

- **Everything is set up in** `C:/wsl/nixos/`: The script uses this directory to store all related files, including the NixOS image, the VHDX for the home directory, and log files.
- **Creates a 5GB VHDX disk**: The script will create a 5GB VHDX file for storing the home directory and format it appropriately.
- **Downloads and applies my NixOS configuration**: It clones the repository located at `https://github.com/Arlind-dev/dotfiles` and applies the NixOS configuration defined within it.
- **Sets a default user password**: It sets the password for the `nixos` user as `nixos`.
- **Updates your WSL configuration if necessary**: If the required settings (`kernelCommandLine = cgroup_no_v1=all`) are missing in your `.wslconfig`, it will update them.
- **Logs are stored in** `C:/wsl/nixos/logs/`: The script creates detailed logs of its operations, stored with timestamps (e.g., `setup_2024-09-31_HH-MM-SS.log`).
- **Re-running the script deletes the existing NixOS WSL instance**: If you already have a NixOS WSL instance, the script will unregister it and create a new one from scratch.
- **Handles administrative privileges**: The script checks if it is running with administrative privileges and restarts itself with elevated permissions if necessary.
- **Installs WSL if not present**: The script checks if WSL is installed and will install it if it's not already present on your system.

#### Prerequisites

- **Git must be installed**: The script will check if Git is installed. If it is not, it will prompt you to install it before continuing.
- **Enable Virtualization in your BIOS**: Ensure that virtualization is enabled in your BIOS settings to support WSL2.

#### Key Configuration Variables

- `$NixOSFolder = "C:\wsl\nixos"`: The base directory for storing NixOS-related files.
- `$LogsFolder = "$NixOSFolder\logs"`: Directory where logs are stored.
- `$NixOSImage = "$NixOSFolder\nixos-wsl.tar.gz"`: Location for the NixOS image.
- `$VHDXPath = "$NixOSFolder\home.vhdx"`: Path to the virtual disk (VHDX file) for storing the home directory.
- `$NixFilesDest = "/home/nixos/.dotfiles/nix"`: Destination path where configuration files will be copied inside NixOS.

#### What the Script Does

1. **Sets up directories and logs**: Ensures that the necessary folders exist and creates log files for tracking the process.
2. **Checks prerequisites**: Verifies that Git is installed. If it is not, it exits with a message asking you to install it.
3. **Handles administrative privileges**: Checks if it is running with administrative rights and restarts itself with elevated permissions if necessary.
4. **Installs WSL if needed**: Checks if WSL is installed, and if not, it installs WSL without any distribution.
5. **Unregisters any existing NixOS instance**: If NixOS is already registered in WSL, the script will unregister it to ensure a clean setup.
6. **Downloads the NixOS image**: If the NixOS image is not found in the specified location, it will download it from GitHub.
7. **Clones the dotfiles repository**: Downloads my configuration from the GitHub repository and applies it to the NixOS instance.
8. **Imports NixOS into WSL**: Imports the NixOS image into WSL and sets it as the default distribution.
9. **Creates and formats a VHDX file**: A 5GB disk is created for the home directory and formatted with `ext4`.
10. **Copies NixOS configuration files**: The script copies configuration files to the appropriate location inside the NixOS instance.
11. **Configures and applies NixOS settings**: Runs `nixos-rebuild switch` using the specified flake to apply the configuration.
12. **Sets up the user password**: Sets the password for the `nixos` user to `nixos`.
13. **Removes old Home Manager profiles and gcroots**: Cleans up any old profiles to avoid conflicts.
14. **Updates WSL configuration**: Backs up your existing `.wslconfig` and updates it with required settings if necessary.
15. **Logs**: All operations are logged in `C:/wsl/nixos/logs/` with timestamped log files.

#### Logs

- Logs are created in the folder `C:/wsl/nixos/logs/`.
- These logs detail each step the script takes, including failures and successes.

#### Running the Script Again

- If the script is run again, it will delete the existing NixOS WSL instance and create a new one. Any changes made to the previous instance will be lost.

### My NixOS Config

This NixOS configuration is structured with modularity and flexibility in mind, allowing for the easy toggling of key features. The setup is designed to work seamlessly within a WSL2 environment but is adaptable to other NixOS setups as well. Below is a breakdown of the configuration’s features and how to use it.

#### Key Features

- **Modular Design**: The configuration is split into multiple modules for packages, virtualization, users, and system settings, making it easy to manage and extend.
- **Toggleable Settings**: Customize your system by enabling or disabling various features through simple flags, such as development tools, virtualization, or desktop environments.
- **WSL2 Specific Settings**: Optimized for use with WSL2, including mounting a 5GB VHDX for the home directory and native systemd support.
- **Default User and Password**: The default username is `nixos`, and the password is set to `nixos` for easy access.

#### Custom Toggleable Options

##### 1. **Virtualization Options**

Managed under `MyNixOS.virtualization`, you can toggle between different virtualization tools:

- `enableDocker = false`: Enable Docker (with rootless mode) and install `docker-compose` if set to `true`.
- `enablePodman = false`: Enable Podman and install `podman-compose` and `podman-tui` if set to `true`.
- **Note**: Only Docker or Podman should be enabled at once.
- `enableK3s = false`: Enable K3s, a lightweight Kubernetes distribution, if set to `true`.
- `enableHelm = false`: Enable Helm (Should only be enabled if K3s is also enabled).

##### 2. **Package Management**

Managed under `MyNixOS.packages`, with separate flags to control the inclusion of different categories of software:

- `enableUtilities = true`: Include essential utilities like `tree`, `unzip`, `ripgrep`, etc.
- `enableDatabaseClients = false`: Include database clients such as `mysql-client`, `postgresql`, `sqlite`.
- `enableDevelopmentTools = false`: Include development tools like `gcc`, `python3`, `cmake`, etc.
- `enableDesktopEnvironment = false`: Enable a graphical desktop environment (KDE Plasma) and services like `xrdp`.

#### Default Programs

A number of useful programs are enabled by default for convenience:

- **Zsh** with Oh My Zsh plugins (`git`) and custom shell aliases like:
  - `rebuild`: Rebuild NixOS.
  - `update`: Update the Nix flake.
  - `sync-dotfiles`: Pull the latest changes from my dotfiles repository.
  - `clean`: Run the Nix garbage collector.
- **Tmux**, **Neovim** (set as default editor), **Git**, and **Nix-LD** for compatibility with dynamic linking, so stuff like `code .` works.

#### Networking and Security

- **SSH**: Configured with a custom port `2222` and disabled root login for added security.
- **Firewall**: Enabled with specific TCP ports open for services:
  - Port `2222`: SSH
  - Port `3390`: XRDP (Remote Desktop)
  - Port `6443`: K3s API Server

#### Additional System Configurations

- **WSL Settings**: Optimized for WSL2 with native systemd support and mounted VHDX for the home directory.
- **Nix Garbage Collection**: Automatically run daily to manage disk space.
- **ZSH Aliases**: Pre-configured for easy Nix management and system maintenance.

#### Usage

You can control which features to enable or disable by modifying the `MyNixOS` settings in your `nixos-config.nix` located in `~/.dotfiles/nix/NixOS/`. For example:

```nix
   MyNixOS.virtualization = {
     enableDocker = true;
     enablePodman = false;
     enableK3s = true;
     enableHelm = true;
   };

   MyNixOS.packages = {
     enableUtilities = true;
     enableDatabaseClients = false;
     enableDevelopmentTools = true;
     enableDesktopEnvironment = true;
   };
```

These settings will automatically adjust the system to include or exclude certain packages and services.
