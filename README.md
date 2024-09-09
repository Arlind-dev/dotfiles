# NixOS Configuration Guide

DONT USE THIS YET IM STILL MAKING A LOT OF CHANGES

This guide outlines the steps to set up NixOS on Virtual Machines (VMs) and Windows Subsystem for Linux (WSL), including importing your NixOS configuration.

## Installing NixOS on WSL

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
