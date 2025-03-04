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
$ScriptPath = "$NixOSFolder\temp.ps1"

# Function Definitions

function Write-OutputLog {
    param ([string]$message)
    Write-Output $message | Out-File -Append $LogFile
}

function Initialize-LogsFolder {
    try {
        if (-Not (Test-Path -Path $LogsFolder)) {
            New-Item -Path $LogsFolder -ItemType Directory -Force | Out-Null
            $message = "Created logs folder at $LogsFolder."
            Write-Host $message
            Write-OutputLog $message
        }
    }
    catch {
        $message = "Failed to create logs folder at $LogsFolder."
        Write-Host $message
        Write-OutputLog $message
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Invoke-CheckAdminElevation {
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        $message = "Script is not running as administrator. Attempting to restart with elevated privileges..."
        Write-Host $message
        Write-OutputLog $message

        $pwshPath = Get-Command pwsh -ErrorAction SilentlyContinue
        $shellPath = if ($pwshPath) { "pwsh.exe" } else { "powershell.exe" }

        $wtPath = Get-Command wt -ErrorAction SilentlyContinue

        if (-not $PSCommandPath) {
            if (-Not (Test-Path -Path $NixOSFolder)) {
                New-Item -Path $NixOSFolder -ItemType Directory -Force | Out-Null
                $message = "Created NixOS folder at $NixOSFolder."
                Write-Host $message
                Write-OutputLog $message
            }

            $scriptContent = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Arlind-dev/dotfiles/main/Windows/setup-wsl.ps1").Content
            Set-Content -Path $ScriptPath -Value $scriptContent
            $message = "Downloaded and saved script content to $ScriptPath."
            Write-Host $message
            Write-OutputLog $message
        }

        if ($wtPath) {
            $message = "Windows Terminal found. Restarting in Windows Terminal with $shellPath..."
            Write-Host $message
            Write-OutputLog $message
            Start-Process -FilePath "wt.exe" -ArgumentList "new-tab $shellPath -NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`"" -Verb RunAs
        }
        else {
            $message = "Windows Terminal not found. Restarting with $shellPath..."
            Write-Host $message
            Write-OutputLog $message
            Start-Process -FilePath $shellPath -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`"" -Verb RunAs
        }

        Exit
    }
}

function Enable-WSLFeature {
    try {
        $message = "Enabling Windows Subsystem for Linux feature..."
        Write-Host $message
        Write-OutputLog $message
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
        $message = "Enabled Windows Subsystem for Linux feature."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to enable Windows Subsystem for Linux feature."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Set-WSLDefaultVersion2 {
    try {
        $message = "Setting WSL default version to 2..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe --set-default-version 2
        $message = "Set WSL default version to 2."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to set WSL default version to 2."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
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
                $message = "Backed up existing .wslconfig to $WSLConfigBackupPath."
                Write-Host $message
                Write-OutputLog $message

                if (-not $hasWSL2Section) {
                    Add-Content -Path $configPath -Value "`r`n$wsl2Section`r`n$newConfigLine"
                    $message = "Added [wsl2] section and updated .wslconfig at $configPath."
                    Write-Host $message
                    Write-OutputLog $message
                }
                else {
                    $wsl2Index = [Array]::IndexOf($currentConfig, $wsl2Section)
                    $contentBeforeWSL2 = $currentConfig[0..$wsl2Index]
                    $contentAfterWSL2 = $currentConfig[($wsl2Index + 1)..($currentConfig.Length - 1)]

                    $newConfig = $contentBeforeWSL2 + $newConfigLine + $contentAfterWSL2
                    Set-Content -Path $configPath -Value $newConfig
                    $message = "Updated .wslconfig at $configPath."
                    Write-Host $message
                    Write-OutputLog $message
                }
            }
            else {
                $message = "No changes needed in .wslconfig."
                Write-Host $message
                Write-OutputLog $message
            }
        }
        else {
            Set-Content -Path $configPath -Value "[wsl2]`r`n$newConfigLine"
            $message = "Created new .wslconfig at $configPath."
            Write-Host $message
            Write-OutputLog $message
        }
    }
    catch {
        $message = "Failed to update .wslconfig."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Install-WSL {
    try {
        $message = "Installing WSL..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe --install --no-distribution
        $message = "WSL installed successfully."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to install WSL."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Unregister-NixOS {
    try {
        $message = "Unregistering NixOS..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe --unregister NixOS
        $message = "NixOS unregistered."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to unregister NixOS."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Invoke-DownloadNixOSImage {
    try {
        $message = "Downloading NixOS image..."
        Write-Host $message
        Write-OutputLog $message
        Invoke-WebRequest -Uri "https://github.com/nix-community/NixOS-WSL/releases/download/2405.5.4/nixos-wsl.tar.gz" -OutFile $NixOSImage
        $message = "Downloaded NixOS image."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to download NixOS image."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Invoke-CloneDotfilesRepository {
    try {
        $message = "Cloning dotfiles repository..."
        Write-Host $message
        Write-OutputLog $message
        git clone $RepoURL $RepoPath
        $message = "Cloned dotfiles repository."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to clone repository."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Update-DotfilesRepository {
    try {
        $message = "Updating dotfiles repository..."
        Write-Host $message
        Write-OutputLog $message
        git -C $RepoPath pull
        $message = "Updated dotfiles repository."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to update repository."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Import-NixOS {
    try {
        $message = "Importing NixOS..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe --import NixOS "$NixOSFolder" "$NixOSImage"
        $message = "Imported NixOS."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to import NixOS."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Set-DefaultWSL {
    try {
        $message = "Setting NixOS as the default WSL distribution..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -s NixOS
        $message = "Set NixOS as default."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to set NixOS as default."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function New-FormatVHD {
    try {
        $message = "Creating and formatting VHD for home directory..."
        Write-Host $message
        Write-OutputLog $message
        New-VHD -Path $VHDXPath -SizeBytes $VHDXSizeGB -Fixed | Out-Null
        $formatDisk = "sudo mkfs.ext4 /mnt/c/wsl/nixos/home.vhdx"
        wsl.exe -d NixOS -- bash -c $formatDisk
        $message = "Created and formatted VHD for home directory."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to create or format VHD."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Copy-NixOSConfigurationFiles {
    try {
        $message = "Copying NixOS configuration files to $NixFilesDest..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "mkdir -p $NixFilesDest"
        wsl.exe -d NixOS -- bash -c "cp -r $NixFilesSource/* $NixFilesDest"
        $message = "Copied NixOS configuration files."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to copy NixOS configuration files."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Invoke-RebuildWithFlake {
    param ([string]$flakePath = "~/.dotfiles/nix")
    try {
        $message = "Rebuilding NixOS with flake configuration at $flakePath..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "sudo nixos-rebuild switch --flake $flakePath"
        $message = "Rebuild with flake at $flakePath completed."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to rebuild NixOS with flake at $flakePath."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred during rebuild: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Stop-WSL {
    try {
        $message = "Shutting down WSL..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe --shutdown
        $message = "WSL shutdown."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to shut down WSL."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Set-Ownership {
    try {
        $message = "Changing ownership of home directory..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "sudo chown -R 1000:100 /home/nixos"
        $message = "Changed ownership of home directory."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to change ownership of home directory."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Set-UserPassword {
    try {
        $message = "Setting password for 'nixos' user..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "echo 'nixos:nixos' | sudo chpasswd"
        $message = "Password for 'nixos' user set."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to set password for 'nixos' user."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Remove-OldHomeManagerProfiles {
    try {
        $message = "Removing old home-manager profiles..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "rm -rf /home/nixos/.local/state/nix/profiles/home-manager*"
        $message = "Removed old home-manager profiles."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to remove old home-manager profiles."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Remove-OldHomeManagerGcroots {
    try {
        $message = "Removing old home-manager gcroots..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "rm -rf /home/nixos/.local/state/home-manager/gcroots/current-home"
        $message = "Removed old home-manager gcroots."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to remove old home-manager gcroots."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function New-NixFilesDirectory {
    try {
        $message = "Creating directory for NixOS configuration files..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "mkdir -p $NixFilesDest"
        $message = "Created directory $NixFilesDest."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to create directory $NixFilesDest."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Copy-NixFiles {
    try {
        $message = "Copying NixOS configuration files..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "cp -r $NixFilesSource/* $NixFilesDest"
        $message = "Copied NixOS configuration files."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to copy NixOS configuration files."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Remove-OldDotfilesRepo {
    try {
        $message = "Removing old dotfiles repository..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "rm -rf ~/.dotfiles/nix"
        $message = "Removed old dotfiles repository."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to remove old dotfiles repository."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function Invoke-CloneNewDotfilesRepo {
    try {
        $message = "Cloning new dotfiles repository..."
        Write-Host $message
        Write-OutputLog $message
        wsl.exe -d NixOS -- bash -c "git clone $RepoURL ~/.dotfiles/nix/"
        $message = "Cloned new dotfiles repository."
        Write-Host $message
        Write-OutputLog $message
    }
    catch {
        $message = "Failed to clone new dotfiles repository."
        Write-Host $message
        Write-OutputLog $message
        $errorMessage = "An error occurred: $_"
        Write-Host $errorMessage
        Write-OutputLog $errorMessage
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

function main {
    Initialize-LogsFolder

    Invoke-CheckAdminElevation

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
        $message = "Git is not installed. Please install Git before proceeding."
        Write-Host $message
        Write-OutputLog $message
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }

    $message = "Starting NixOS WSL setup..."
    Write-Host $message
    Write-OutputLog $message

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

    $message = "Setup complete."
    Write-Host $message
    Write-OutputLog $message

    Read-Host -Prompt "Press Enter to exit"
}

main
