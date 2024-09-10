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
$HomePath = $env:USERPROFILE
$WSLConfigPath = "$HomePath\.wslconfig"
$WSLConfigBackupPath = "$HomePath\.wslconfigcopy"
$VHDXSizeGB = 5GB

function Write-OutputLog {
    param (
        [string]$message
    )
    Write-Output $message | Out-File -Append $LogFile
}

function Update-WSLConfig {
    param (
        [string]$configPath
    )
    $newConfig = @"
[wsl2]
localhostForwarding=true
kernelCommandLine = cgroup_no_v1=all
"@
    if (Test-Path -Path $configPath) {
        $currentConfig = Get-Content -Path $configPath
        $configNeedsUpdate = $false

        if (-not ($currentConfig -match 'localhostForwarding=true')) { $configNeedsUpdate = $true }
        if (-not ($currentConfig -match 'kernelCommandLine\s*=\s*cgroup_no_v1=all')) { $configNeedsUpdate = $true }

        if ($configNeedsUpdate) {
            $choice = Read-Host "Your .wslconfig has different values. Would you like to update it? (yes/no)"
            if ($choice -eq "yes") {
                Copy-Item -Path $configPath -Destination $WSLConfigBackupPath
                Set-Content -Path $configPath -Value $newConfig
                Write-OutputLog "Updated .wslconfig and backed up original to $WSLConfigBackupPath."
                Write-Host ".wslconfig updated and backup created."
            } else {
                Write-Host ".wslconfig not changed."
            }
        } else {
            Write-Host ".wslconfig is already configured correctly."
        }
    } else {
        Set-Content -Path $configPath -Value $newConfig
        Write-Host "Created new .wslconfig at $configPath."
        Write-OutputLog "Created new .wslconfig."
    }
}

Update-WSLConfig $WSLConfigPath

try {
    if (-Not (Test-Path -Path $LogsFolder)) {
        New-Item -Path $LogsFolder -ItemType Directory
        Write-Host "Created logs folder at $LogsFolder."
    }
} catch {
    Write-Host "Failed to create logs folder at $LogsFolder."
    Exit 1
}

if (-Not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-OutputLog "Git is not installed. Please install Git before proceeding."
    Exit 1
}

if (-Not (Get-Command wget -ErrorAction SilentlyContinue)) {
    Write-OutputLog "Wget is not installed. Please install Wget before proceeding."
    Exit 1
}

Write-OutputLog "Starting NixOS WSL setup..."

$wslCheck = wsl.exe --version 2>$null
if (-Not $wslCheck) {
    try {
        wsl.exe --install --no-distribution
        Write-OutputLog "WSL installed successfully."
    } catch {
        Write-OutputLog "Failed to install WSL."
        Exit 1
    }
}

$wslInstances = wsl.exe -l -q
if ($wslInstances -contains "NixOS") {
    try {
        wsl.exe --unregister NixOS
        Write-OutputLog "NixOS unregistered."
    } catch {
        Write-OutputLog "Failed to unregister NixOS."
        Exit 1
    }
}

if (-Not (Test-Path -Path $NixOSImage)) {
    try {
        Invoke-WebRequest -Uri "https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos-wsl.tar.gz" -OutFile $NixOSImage
        Write-OutputLog "Downloaded NixOS image."
    } catch {
        Write-OutputLog "Failed to download NixOS image."
        Exit 1
    }
}

if (-Not (Test-Path -Path $RepoPath)) {
    try {
        git clone $RepoURL $RepoPath
        Write-OutputLog "Cloned dotfiles repository."
    } catch {
        Write-OutputLog "Failed to clone repository."
        Exit 1
    }
} else {
    try {
        Set-Location -Path $RepoPath
        git pull
        Write-OutputLog "Updated dotfiles repository."
    } catch {
        Write-OutputLog "Failed to update repository."
        Exit 1
    }
}

try {
    wsl.exe --import NixOS "$NixOSFolder" "$NixOSImage"
    Write-OutputLog "Imported NixOS."
} catch {
    Write-OutputLog "Failed to import NixOS."
    Exit 1
}

try {
    wsl.exe -s NixOS
    Write-OutputLog "Set NixOS as default."
} catch {
    Write-OutputLog "Failed to set NixOS as default."
    Exit 1
}

if (-Not (Test-Path -Path $VHDXPath)) {
    try {
        New-VHD -Path $VHDXPath -SizeBytes $VHDXSizeGB -Fixed
        $formatDisk = "sudo mkfs.ext4 /mnt/c/wsl/nixos/home.vhdx"
        wsl.exe -d NixOS -- bash -c $formatDisk
        Write-OutputLog "Created and formatted VHD for home directory."
    } catch {
        Write-OutputLog "Failed to create or format VHD."
        Exit 1
    }
}

try {
    Write-Host "Copying NixOS configuration files to $NixFilesDest..."
    wsl.exe -d NixOS -- bash -c "mkdir -p $NixFilesDest"
    wsl.exe -d NixOS -- bash -c "cp -r $NixFilesSource/* $NixFilesDest"
    Write-OutputLog "Copied NixOS configuration files."
} catch {
    Write-OutputLog "Failed to copy NixOS configuration files."
    Exit 1
}

try {
    Write-Host "Rebuild with flake in progress, this may take a few minutes..."
    wsl.exe -d NixOS -- bash -c "sudo nixos-rebuild switch --flake ~/.dotfiles/nix"
    Write-OutputLog "Rebuild with flake completed."
} catch {
    Write-OutputLog "Failed to rebuild NixOS with flake. Rebooting WSL and trying again..."
}

try {
    Write-Host "Shutting down WSL..."
    wsl.exe --shutdown
    Write-OutputLog "WSL shutdown."
} catch {
    Write-OutputLog "Failed to shut down WSL."
    Exit 1
}

try {
    Write-Host "Changing ownership of home directory..."
    wsl.exe -d NixOS -- bash -c "sudo chown -R 1000:100 /home/nixos"
    Write-OutputLog "Changed ownership of home directory."
} catch {
    Write-OutputLog "Failed to change ownership of home directory."
    Exit 1
}

try {
    Write-Host "Setting password for 'nixos' user..."
    wsl.exe -d NixOS -- bash -c "echo 'nixos:nixos' | sudo chpasswd" # For xrdp
    Write-OutputLog "Password for 'nixos' user set."
} catch {
    Write-OutputLog "Failed to set password for 'nixos' user."
    Exit 1
}

try {
    Write-Host "Removing old home-manager profiles..."
    wsl.exe -d NixOS -- bash -c "rm /home/nixos/.local/state/nix/profiles/home-manager*"
    Write-OutputLog "Removed old home-manager profiles."
} catch {
    Write-OutputLog "Failed to remove old home-manager profiles."
    Exit 1
}

try {
    Write-Host "Removing old home-manager gcroots..."
    wsl.exe -d NixOS -- bash -c "rm /home/nixos/.local/state/home-manager/gcroots/current-home"
    Write-OutputLog "Removed old home-manager gcroots."
} catch {
    Write-OutputLog "Failed to remove old home-manager gcroots."
    Exit 1
}

try {
    Write-Host "Creating directory for NixOS configuration files..."
    wsl.exe -d NixOS -- bash -c "mkdir -p $NixFilesDest"
    Write-OutputLog "Created directory $NixFilesDest."
} catch {
    Write-OutputLog "Failed to create directory $NixFilesDest."
    Exit 1
}

try {
    Write-Host "Copying NixOS configuration files..."
    wsl.exe -d NixOS -- bash -c "cp -r $NixFilesSource/* $NixFilesDest"
    Write-OutputLog "Copied NixOS configuration files."
} catch {
    Write-OutputLog "Failed to copy NixOS configuration files."
    Exit 1
}

try {
    Write-Host "Rebuilding NixOS with flake configuration..."
    wsl.exe -d NixOS -- bash -c "sudo nixos-rebuild switch --flake ~/.dotfiles/nix"
    Write-OutputLog "Rebuild with flake completed."
} catch {
    Write-OutputLog "Failed to rebuild NixOS with flake configuration."
    Exit 1
}

try {
    Write-Host "Removing old dotfiles repository..."
    wsl.exe -d NixOS -- bash -c "rm -rf ~/.dotfiles/nix"
    Write-OutputLog "Removed old dotfiles repository."
} catch {
    Write-OutputLog "Failed to remove old dotfiles repository."
    Exit 1
}

try {
    Write-Host "Cloning new dotfiles repository..."
    wsl.exe -d NixOS -- bash -c "git clone https://github.com/Arlind-dev/dotfiles ~/.dotfiles/nix/"
    Write-OutputLog "Cloned new dotfiles repository."
} catch {
    Write-OutputLog "Failed to clone new dotfiles repository."
    Exit 1
}

try {
    Write-Host "Rebuilding NixOS with new flake configuration..."
    wsl.exe -d NixOS -- bash -c "sudo nixos-rebuild switch --flake ~/.dotfiles/nix/NixOS/"
    Write-OutputLog "Final rebuild with new flake completed."
} catch {
    Write-OutputLog "Failed to perform final rebuild with new flake."
    Exit 1
}

Write-Host "Setup complete."
Write-OutputLog "Setup complete."
