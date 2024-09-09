$NixOSFolder = "C:\wsl\nixos"
$LogsFolder = "$NixOSFolder\logs"
$CurrentDateTime = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$LogFile = "$LogsFolder\setup_$CurrentDateTime.log"
$NixOSImage = "$NixOSFolder\nixos-wsl.tar.gz"
$VHDXPath = "$NixOSFolder\home.vhdx"
$RepoURL = "https://github.com/Arlind-dev/dotfiles"
$RepoPath = "$NixOSFolder\dotfiles"
$NixFilesSource = "/mnt/c/wsl/nixos/dotfiles/NixOS"
$NixFilesDest = "/home/nixos/.dotfiles/nix"

try {
    if (-Not (Test-Path -Path $LogsFolder)) {
        New-Item -Path $LogsFolder -ItemType Directory
        Write-Host "Created logs folder at $LogsFolder."
    }
} catch {
    Write-Host "Failed to create logs folder at $LogsFolder."
    Exit 1
}

function Log-Output {
    param (
        [string]$message
    )
    Write-Output $message | Out-File -Append $LogFile
}

if (-Not (Get-Command git -ErrorAction SilentlyContinue)) {
    Log-Output "Git is not installed. Please install Git before proceeding."
    Exit 1
}

if (-Not (Get-Command wget -ErrorAction SilentlyContinue)) {
    Log-Output "Wget is not installed. Please install Wget before proceeding."
    Exit 1
}

Log-Output "Starting NixOS WSL setup..."

$wslCheck = wsl.exe --version 2>$null
if (-Not $wslCheck) {
    try {
        wsl.exe --install --no-distribution
        Log-Output "WSL installed successfully."
    } catch {
        Log-Output "Failed to install WSL."
        Exit 1
    }
}

$wslInstances = wsl.exe -l -q
if ($wslInstances -contains "NixOS") {
    try {
        wsl.exe --unregister NixOS
        Log-Output "NixOS unregistered."
    } catch {
        Log-Output "Failed to unregister NixOS."
        Exit 1
    }
}

if (-Not (Test-Path -Path $NixOSImage)) {
    try {
        Invoke-WebRequest -Uri "https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos-wsl.tar.gz" -OutFile $NixOSImage
        Log-Output "Downloaded NixOS image."
    } catch {
        Log-Output "Failed to download NixOS image."
        Exit 1
    }
}

if (-Not (Test-Path -Path $RepoPath)) {
    try {
        git clone $RepoURL $RepoPath
        Log-Output "Cloned dotfiles repository."
    } catch {
        Log-Output "Failed to clone repository."
        Exit 1
    }
} else {
    try {
        Set-Location -Path $RepoPath
        git pull
        Log-Output "Updated dotfiles repository."
    } catch {
        Log-Output "Failed to update repository."
        Exit 1
    }
}

try {
    wsl.exe --import NixOS "$NixOSFolder" "$NixOSImage"
    Log-Output "Imported NixOS."
} catch {
    Log-Output "Failed to import NixOS."
    Exit 1
}

try {
    wsl.exe -s NixOS
    Log-Output "Set NixOS as default."
} catch {
    Log-Output "Failed to set NixOS as default."
    Exit 1
}

if (-Not (Test-Path -Path $VHDXPath)) {
    try {
        New-VHD -Path $VHDXPath -SizeBytes 20GB -Dynamic
        $formatDisk = "sudo mkfs.ext4 /mnt/c/wsl/nixos/home.vhdx"
        wsl.exe -d NixOS -- bash -c $formatDisk
        Log-Output "Created and formatted VHD for home directory."
    } catch {
        Log-Output "Failed to create or format VHD."
        Exit 1
    }
}

try {
    Write-Host "Copying NixOS configuration files to $NixFilesDest..."
    wsl.exe -d NixOS -- bash -c "mkdir -p $NixFilesDest"
    wsl.exe -d NixOS -- bash -c "cp -r $NixFilesSource/* $NixFilesDest"
    Log-Output "Copied NixOS configuration files."
} catch {
    Log-Output "Failed to copy NixOS configuration files."
    Exit 1
}

# Rebuild NixOS using flake
try {
    Write-Host "Rebuild with flake in progress, this may take a few minutes...."
    wsl.exe -d NixOS -- bash -c "sudo nixos-rebuild switch --flake ~/.dotfiles/nix"
    Log-Output "Rebuild with flake completed."
} catch {
    Log-Output "Failed to rebuild NixOS with flake. Rebooting WSL and trying again..."
}

try {
    wsl.exe --shutdown
    Log-Output "WSL shutdown."
} catch {
    Log-Output "Failed to shut down WSL."
    Exit 1
}

try {
    wsl.exe -d NixOS -- bash -c "sudo chown -R 1000:100 /home/nixos"
    Log-Output "Changed ownership of home directory."
    wsl.exe -d NixOS -- bash -c "mkdir -p $NixFilesDest"
    wsl.exe -d NixOS -- bash -c "cp -r $NixFilesSource/* $NixFilesDest"
    Log-Output "Re-copied configuration files."
    wsl.exe -d NixOS -- bash -c "sudo nixos-rebuild switch --flake ~/.dotfiles/nix"
    Log-Output "Final rebuild with flake completed."
} catch {
    Log-Output "Failed during final setup steps."
    Exit 1
}

Write-Host "Setup complete."
Log-Output "Setup complete."
