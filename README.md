# NixOS Config
My NixOS configuration.nix that I use for my NixOS VMs including my WSL.

## Installing WSL with NixOS

1. Enable WSL if you haven't done already:

```PowerShell
wsl --install --no-distribution
```

2. Download `nixos-wsl.tar.gz` from the [latest release](https://github.com/nix-community/NixOS-WSL/releases/latest).

3. Import the tarball into WSL:

```PowerShell
wsl --import NixOS --version 2 $env:USERPROFILE\NixOS\ nixos-wsl.tar.gz
```

4. Set as default distribution:
```PowerShell
wsl -s NixOS
```

5. Run WSL
```PowerShell
wsl
```

## Importing NixOS Config

```bash
cp configuration.nix /etc/nixos/configuration.nix
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update
sudo nixos-rebuild switch
```
