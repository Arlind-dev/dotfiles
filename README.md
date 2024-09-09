# NixOS Configuration Guide

DONT USE THIS YET IM STILL MAKING A LOT OF CHANGES

This guide outlines the steps to set up NixOS on Virtual Machines (VMs) and Windows Subsystem for Linux (WSL), including importing your NixOS configuration.

## Setting Up WSL with NixOS

### Configuring WSL on Windows

Create or modify the `~/.wslconfig` file in Windows with the following content:

```ini
[wsl2]
localhostForwarding=true
nestedVirtualization=true
kernelCommandLine = cgroup_no_v1=all
```

### Installing NixOS on WSL

1. **Install WSL**

   Open PowerShell and run:

   ```PowerShell
   IInvoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Arlind-dev/dotfiles/main/Windows/setup-wsl.ps1").Content
   ```

2. **Launch WSL:**

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
