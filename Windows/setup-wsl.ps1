# Elevation Check and Re-launch with Admin Rights if Necessary
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Script is not running as administrator. Attempting to restart with elevated privileges..."

    $pwshPath = Get-Command pwsh -ErrorAction SilentlyContinue
    $shellPath = if ($pwshPath) { "pwsh.exe" } else { "powershell.exe" }

    $wtPath = Get-Command wt -ErrorAction SilentlyContinue
    if ($wtPath) {
        Write-Host "Windows Terminal found. Restarting in Windows Terminal with $shellPath..."
        Start-Process -FilePath "wt.exe" -ArgumentList "new-tab $shellPath -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    else {
        Write-Host "Windows Terminal not found. Restarting with $shellPath..."
        Start-Process -FilePath $shellPath -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    Exit
}

# Variable Definitions
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

# Function Definitions

function Write-OutputLog {
    param ([string]$message)
    Write-Output $message | Out-File -Append $LogFile
}

function Initialize-LogsFolder {
    try {
        if (-Not (Test-Path -Path $LogsFolder)) {
            New-Item -Path $LogsFolder -ItemType Directory -Force | Out-Null
            Write-Host "Created logs folder at $LogsFolder."
        }
    }
    catch {
        Write-Host "Failed to create logs folder at $LogsFolder."
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Enable-WSLFeature {
    try {
        Write-Host "Enabling Windows Subsystem for Linux feature..."
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
        Write-OutputLog "Enabled Windows Subsystem for Linux feature."
    }
    catch {
        Write-OutputLog "Failed to enable Windows Subsystem for Linux feature."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Set-WSLDefaultVersion2 {
    try {
        wsl.exe --set-default-version 2
        Write-OutputLog "Set WSL default version to 2."
    }
    catch {
        Write-OutputLog "Failed to set WSL default version to 2."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Update-WSLConfig {
    param ([string]$configPath)

    $newConfigLine = "kernelCommandLine = cgroup_no_v1=all"
    $wsl2Section = "[wsl2]"

    try {
        if (Test-Path -Path $configPath) {
            $currentConfig = Get-Content -Path $configPath

            $hasWSL2Section = $currentConfig -contains $wsl2Section
            $hasKernelCommandLine = $currentConfig -contains $newConfigLine

            if (-not $hasKernelCommandLine) {
                Copy-Item -Path $configPath -Destination $WSLConfigBackupPath -Force
                Write-OutputLog "Backed up existing .wslconfig to $WSLConfigBackupPath."
                Write-Host "Backed up existing .wslconfig to $WSLConfigBackupPath."

                if (-not $hasWSL2Section) {
                    Add-Content -Path $configPath -Value "`r`n$wsl2Section`r`n$newConfigLine"
                    Write-Host "Added [wsl2] section and updated .wslconfig at $configPath."
                    Write-OutputLog "Added [wsl2] section and updated .wslconfig at $configPath."
                }
                else {
                    $wsl2Index = [Array]::IndexOf($currentConfig, $wsl2Section)
                    $contentBeforeWSL2 = $currentConfig[0..$wsl2Index]
                    $contentAfterWSL2 = $currentConfig[($wsl2Index + 1)..($currentConfig.Length - 1)]

                    $newConfig = $contentBeforeWSL2 + $newConfigLine + $contentAfterWSL2
                    Set-Content -Path $configPath -Value $newConfig
                    Write-Host "Updated .wslconfig at $configPath."
                    Write-OutputLog "Updated .wslconfig at $configPath."
                }
            }
            else {
                Write-Host "No changes needed in .wslconfig."
                Write-OutputLog "No changes needed in .wslconfig."
            }
        }
        else {
            Set-Content -Path $configPath -Value "[wsl2]`r`n$newConfigLine"
            Write-Host "Created new .wslconfig at $configPath."
            Write-OutputLog "Created new .wslconfig at $configPath."
        }
    }
    catch {
        Write-OutputLog "Failed to update .wslconfig."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}


function Install-WSL {
    try {
        wsl.exe --install --no-distribution
        Write-OutputLog "WSL installed successfully."
    }
    catch {
        Write-OutputLog "Failed to install WSL."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Unregister-NixOS {
    try {
        wsl.exe --unregister NixOS
        Write-OutputLog "NixOS unregistered."
    }
    catch {
        Write-OutputLog "Failed to unregister NixOS."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Invoke-DownloadNixOSImage {
    try {
        Invoke-WebRequest -Uri "https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos-wsl.tar.gz" -OutFile $NixOSImage
        Write-OutputLog "Downloaded NixOS image."
    }
    catch {
        Write-OutputLog "Failed to download NixOS image."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Invoke-CloneDotfilesRepository {
    try {
        git clone $RepoURL $RepoPath
        Write-OutputLog "Cloned dotfiles repository."
    }
    catch {
        Write-OutputLog "Failed to clone repository."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Update-DotfilesRepository {
    try {
        git -C $RepoPath pull
        Write-OutputLog "Updated dotfiles repository."
    }
    catch {
        Write-OutputLog "Failed to update repository."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Import-NixOS {
    try {
        wsl.exe --import NixOS "$NixOSFolder" "$NixOSImage"
        Write-OutputLog "Imported NixOS."
    }
    catch {
        Write-OutputLog "Failed to import NixOS."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Set-DefaultWSL {
    try {
        wsl.exe -s NixOS
        Write-OutputLog "Set NixOS as default."
    }
    catch {
        Write-OutputLog "Failed to set NixOS as default."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function New-FormatVHD {
    try {
        New-VHD -Path $VHDXPath -SizeBytes $VHDXSizeGB -Fixed | Out-Null
        $formatDisk = "sudo mkfs.ext4 /mnt/c/wsl/nixos/home.vhdx"
        wsl.exe -d NixOS -- bash -c $formatDisk
        Write-OutputLog "Created and formatted VHD for home directory."
    }
    catch {
        Write-OutputLog "Failed to create or format VHD."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Copy-NixOSConfigurationFiles {
    try {
        Write-Host "Copying NixOS configuration files to $NixFilesDest..."
        wsl.exe -d NixOS -- bash -c "mkdir -p $NixFilesDest"
        wsl.exe -d NixOS -- bash -c "cp -r $NixFilesSource/* $NixFilesDest"
        Write-OutputLog "Copied NixOS configuration files."
    }
    catch {
        Write-OutputLog "Failed to copy NixOS configuration files."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Invoke-RebuildWithFlake {
    param ([string]$flakePath = "~/.dotfiles/nix")
    try {
        Write-Host "Rebuilding NixOS with flake configuration at $flakePath..."
        wsl.exe -d NixOS -- bash -c "sudo nixos-rebuild switch --flake $flakePath"
        Write-OutputLog "Rebuild with flake at $flakePath completed."
    }
    catch {
        Write-OutputLog "Failed to rebuild NixOS with flake at $flakePath."
        Write-Host "An error occurred during rebuild: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Stop-WSL {
    try {
        Write-Host "Shutting down WSL..."
        wsl.exe --shutdown
        Write-OutputLog "WSL shutdown."
    }
    catch {
        Write-OutputLog "Failed to shut down WSL."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Set-Ownership {
    try {
        Write-Host "Changing ownership of home directory..."
        wsl.exe -d NixOS -- bash -c "sudo chown -R 1000:100 /home/nixos"
        Write-OutputLog "Changed ownership of home directory."
    }
    catch {
        Write-OutputLog "Failed to change ownership of home directory."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Set-UserPassword {
    try {
        Write-Host "Setting password for 'nixos' user..."
        wsl.exe -d NixOS -- bash -c "echo 'nixos:nixos' | sudo chpasswd"
        Write-OutputLog "Password for 'nixos' user set."
    }
    catch {
        Write-OutputLog "Failed to set password for 'nixos' user."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Remove-OldHomeManagerProfiles {
    try {
        Write-Host "Removing old home-manager profiles..."
        wsl.exe -d NixOS -- bash -c "rm -rf /home/nixos/.local/state/nix/profiles/home-manager*"
        Write-OutputLog "Removed old home-manager profiles."
    }
    catch {
        Write-OutputLog "Failed to remove old home-manager profiles."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Remove-OldHomeManagerGcroots {
    try {
        Write-Host "Removing old home-manager gcroots..."
        wsl.exe -d NixOS -- bash -c "rm -rf /home/nixos/.local/state/home-manager/gcroots/current-home"
        Write-OutputLog "Removed old home-manager gcroots."
    }
    catch {
        Write-OutputLog "Failed to remove old home-manager gcroots."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function New-NixFilesDirectory {
    try {
        Write-Host "Creating directory for NixOS configuration files..."
        wsl.exe -d NixOS -- bash -c "mkdir -p $NixFilesDest"
        Write-OutputLog "Created directory $NixFilesDest."
    }
    catch {
        Write-OutputLog "Failed to create directory $NixFilesDest."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Copy-NixFiles {
    try {
        Write-Host "Copying NixOS configuration files..."
        wsl.exe -d NixOS -- bash -c "cp -r $NixFilesSource/* $NixFilesDest"
        Write-OutputLog "Copied NixOS configuration files."
    }
    catch {
        Write-OutputLog "Failed to copy NixOS configuration files."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Remove-OldDotfilesRepo {
    try {
        Write-Host "Removing old dotfiles repository..."
        wsl.exe -d NixOS -- bash -c "rm -rf ~/.dotfiles/nix"
        Write-OutputLog "Removed old dotfiles repository."
    }
    catch {
        Write-OutputLog "Failed to remove old dotfiles repository."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Invoke-CloneNewDotfilesRepo {
    try {
        Write-Host "Cloning new dotfiles repository..."
        wsl.exe -d NixOS -- bash -c "git clone https://github.com/Arlind-dev/dotfiles ~/.dotfiles/nix/"
        Write-OutputLog "Cloned new dotfiles repository."
    }
    catch {
        Write-OutputLog "Failed to clone new dotfiles repository."
        Write-Host "An error occurred: $_"
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

# Main Execution Flow

Initialize-LogsFolder

$dismOutput = dism.exe /online /get-featureinfo /featurename:Microsoft-Windows-Subsystem-Linux | Select-String "State : (\w+)"
$wslFeatureState = $dismOutput.Matches[0].Groups[1].Value
if ($wslFeatureState -ne "Enabled") {
    Enable-WSLFeature
}

Set-WSLDefaultVersion2

if (-Not (Test-Path -Path $WSLConfigPath) -or -Not ((Get-Content -Path $WSLConfigPath -ErrorAction SilentlyContinue) -match 'kernelCommandLine\s*=\s*cgroup_no_v1=all')) {
    Update-WSLConfig $WSLConfigPath
}

if (-Not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-OutputLog "Git is not installed. Please install Git before proceeding."
    Write-Host "Git is not installed. Please install Git before proceeding."
    Read-Host -Prompt "Press Enter to exit"
    Exit 1
}

if (-Not (Get-Command wget -ErrorAction SilentlyContinue)) {
    Write-OutputLog "Wget is not installed. Please install Wget before proceeding."
    Write-Host "Wget is not installed. Please install Wget before proceeding."
    Read-Host -Prompt "Press Enter to exit"
    Exit 1
}

Write-OutputLog "Starting NixOS WSL setup..."

$wslCheck = wsl.exe --version 2>$null
if (-Not $wslCheck) {
    Install-WSL
}

$wslInstances = wsl.exe -l -q
if ($wslInstances -contains "NixOS") {
    Unregister-NixOS
}

if (-Not (Test-Path -Path $NixOSImage)) {
    Invoke-DownloadNixOSImage
}

if (-Not (Test-Path -Path $RepoPath)) {
    Invoke-CloneDotfilesRepository
}
else {
    Update-DotfilesRepository
}

Import-NixOS

Set-DefaultWSL

if (-Not (Test-Path -Path $VHDXPath)) {
    New-FormatVHD
}

Copy-NixOSConfigurationFiles

Invoke-RebuildWithFlake "~/.dotfiles/nix"

Stop-WSL

Set-Ownership

Set-UserPassword

Remove-OldHomeManagerProfiles

Remove-OldHomeManagerGcroots

New-NixFilesDirectory

Copy-NixFiles

Invoke-RebuildWithFlake "~/.dotfiles/nix"

Remove-OldDotfilesRepo

Invoke-CloneNewDotfilesRepo

Invoke-RebuildWithFlake "~/.dotfiles/nix/NixOS/"

Write-Host "Setup complete."
Write-OutputLog "Setup complete."

Read-Host -Prompt "Press Enter to exit"
