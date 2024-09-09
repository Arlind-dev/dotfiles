# My NixOS Config

This guide outlines the steps to set up NixOS on Virtual Machines (VMs) and Windows Subsystem for Linux (WSL), including importing **my NixOS configuration**.

## Installing my NixOS on WSL

1. **Install WSL**

   Open PowerShell and run:

   ```PowerShell
   Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Arlind-dev/dotfiles/main/Windows/setup-wsl.ps1").Content
   ```

2. **Launch WSL:**

   Simply type:

   ```PowerShell
   wsl
   ```

## Details

### My `setup-wsl.ps1` Script

This script sets up and configures a NixOS environment within WSL2. It performs tasks such as downloading the NixOS image, setting up the disk, cloning **my configuration**, and applying it to the system. Below is an explanation of how the script works and what you need to know.

#### Key Features

- **Everything is set up in** `C:/wsl/nixos/`: The script uses this directory to store all related files including the NixOS image, the VHDX for the home directory, and log files.
- **Creates a 5GB VHDX disk**: The script will create a 5GB VHDX file for storing the home directory and format it appropriately.
- **Downloads and applies my NixOS configuration**: It clones the repository located at `https://github.com/Arlind-dev/dotfiles` and applies the NixOS configuration defined within it.
- **Sets a default user password**: It sets the password for the `nixos` user as `nixos`.
- **Updates my WSL configuration if necessary**: If the required settings (such as `localhostForwarding` and `nestedVirtualization`) are missing in my `.wslconfig`, it will offer to update them.
- **Logs are stored in** `C:/wsl/nixos/logs/`: The script creates detailed logs of its operations, stored with timestamps (e.g., `setup_2024-09-31_hh-mm-ss.log`).
- **Re-running the script deletes the existing NixOS WSL instance**: If I already have a NixOS WSL instance, the script will unregister it and create a new one from scratch.

#### Prerequisites

- **Git and Wget must be installed**: The script will check if these tools are installed. If they are not, it will prompt me to install them before continuing.

#### Key Configuration Variables

- `$NixOSFolder = "C:\wsl\nixos"`: The base directory for storing NixOS-related files.
- `$LogsFolder = "$NixOSFolder\logs"`: Directory where logs are stored.
- `$NixOSImage = "$NixOSFolder\nixos-wsl.tar.gz"`: Location for the NixOS image.
- `$VHDXPath = "$NixOSFolder\home.vhdx"`: Path to the virtual disk (VHDX file) for storing the home directory.
- `$NixFilesDest = "/home/nixos/.dotfiles/nix"`: Destination path where configuration files will be copied inside NixOS.

#### What the Script Does

1. **Sets up directories and logs**: Ensures that the necessary folders exist and creates log files for tracking the process.
2. **Checks prerequisites**: Verifies that Git and Wget are installed. If they aren’t, it exits with a message asking me to install them.
3. **Installs WSL if necessary**: If WSL isn’t installed, the script will attempt to install it.
4. **Unregisters any existing NixOS instance**: If NixOS is already registered in WSL, the script will unregister it to ensure a clean setup.
5. **Downloads the NixOS image**: If the NixOS image is not found in the specified location, it will download it from GitHub.
6. **Clones the dotfiles repository**: Downloads my configuration from the GitHub repository and applies it to the NixOS instance.
7. **Creates and formats a VHDX file**: A 5GB disk is created for the home directory and formatted with `ext4`.
8. **Configures and applies NixOS settings**: The script copies configuration files to the appropriate location and runs `nixos-rebuild switch` using the specified flake.
9. **Sets up the user password**: Sets the password for the `nixos` user to `nixos`.
10. **Modifies WSL settings**: If needed, the script will back up my existing `.wslconfig` and update it with required settings.

#### Logs

- Logs are created in the folder `C:/wsl/nixos/logs/`.
- These logs detail each step the script takes, including failures and successes.

#### Running the Script Again

- If the script is run again, it will delete the existing NixOS WSL instance and create a new one. Any changes made to the previous instance will be lost.

Feel free to modify the template to suit my project’s needs!

### My NixOS Config

This NixOS configuration is structured with modularity and flexibility in mind, allowing for the easy toggling of key features. The setup is designed to work seamlessly within a WSL2 environment but is adaptable to other NixOS setups as well. Below is a breakdown of the configuration’s features and how to use it.

#### Key Features

- **Modular Design**: The configuration is split into multiple modules for packages, virtualization, users, and system settings, making it easy to manage and extend.
- **Toggleable Settings**: Customize my system by enabling or disabling various features through simple flags, such as development tools, virtualization, or desktop environments.
- **WSL2 Specific Settings**: Optimized for use with WSL2, including mounting a 5GB VHDX for the home directory and native systemd support.
- **Default User and Password**: The default username is `nixos`, and the password is set to `nixos` for easy access.

#### Custom Toggleable Options

##### 1. **Virtualization Options**

Managed under `MyNixOS.virtualization`, I can toggle between different virtualization tools:

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
  - `rebuild`: Rebuild NixOS with my configuration.
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

I can control which features to enable or disable by modifying the `MyNixOS` settings in my `configuration.nix`. For example:

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
