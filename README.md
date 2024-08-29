# NixOS Configuration Guide

This guide outlines the steps to set up NixOS on Virtual Machines (VMs) and Windows Subsystem for Linux (WSL), including importing your NixOS configuration.

## Setting Up WSL with NixOS

### Configuring WSL on Windows

Create or modify the `~/.wslconfig` file in Windows with the following content:

```ini
[wsl2]
localhostForwarding=true
kernelCommandLine = cgroup_no_v1=all
```

### Installing NixOS on WSL

1. **Enable WSL:**

   Open PowerShell and run:

   ```PowerShell
   wsl --install --no-distribution
   ```

2. **Download the NixOS WSL Tarball:**

   Get the latest `nixos-wsl.tar.gz` from the [latest release](https://github.com/nix-community/NixOS-WSL/releases/latest).

3. **Import NixOS into WSL:**

   In PowerShell, execute:

   ```PowerShell
   wsl --import NixOS --version 2 $env:USERPROFILE\NixOS\ nixos-wsl.tar.gz
   ```

4. **Set NixOS as the Default Distribution:**

   Run:

   ```PowerShell
   wsl -s NixOS
   ```

5. **Launch WSL:**

   Simply type:

   ```PowerShell
   wsl
   ```

## Importing Your NixOS Configuration

To import your NixOS configuration, follow these steps:

1. **Copy the Configuration File:**

   ```bash
   cp configuration.nix /etc/nixos/configuration.nix
   ```

2. **Add Nix Channels:**

   ```bash
   sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
   sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
   sudo nix-channel --add https://nixos.org/channels/nixos-24.05 nixos-24.05
   ```

3. **Update Channels and Rebuild:**

   ```bash
   sudo nix-channel --update
   sudo nixos-rebuild switch
   ```

4. **Reboot WSL**

   ```Bash
   exit
   ```

   ```PowerShell
   wsl -d NixOS --shutdown
   wsl -d NixOS
   ```

5. **Reapply config**

   ```Bash
   sudo nixos-rebuild switch
   ```

6. **Set Password for use nixos (so RDP works)**

   ```Bash
   sudo passwd nixos
   ```

By following these instructions, you should have NixOS running smoothly on both your VMs and WSL, with your configurations properly applied.
