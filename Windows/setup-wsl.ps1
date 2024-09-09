$NixOSFolder = "C:/wsl/nixos"
$NixOSImage = "$NixOSFolder/nixos-wsl.tar.gz"
$VHDXPath = "$NixOSFolder/home.vhdx"
$RepoURL = "https://github.com/Arlind-dev/dotfiles"
$RepoPath = "$NixOSFolder/dotfiles"

$wslCheck = wsl.exe --version 2>$null

if (-Not $wslCheck) {
    Write-Host "WSL is not installed. Installing WSL..."
    wsl.exe --install --no-distribution
} else {
    Write-Host "WSL is already installed."
}

$wslInstances = wsl.exe -l -q
if ($wslInstances -contains "NixOS") {
    Write-Host "Unregistering existing NixOS instance..."
    wsl.exe --unregister NixOS
}

if (-Not (Test-Path -Path $NixOSImage)) {
    Write-Host "NixOS image not found. Downloading..."
    if (-Not (Test-Path -Path $NixOSFolder)) {
        New-Item -Path $NixOSFolder -ItemType Directory
    }
    Invoke-WebRequest -Uri "https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos-wsl.tar.gz" -OutFile $NixOSImage
}

if (-Not (Test-Path -Path $RepoPath)) {
    Write-Host "Cloning the repository into $RepoPath..."
    git clone $RepoURL $RepoPath
} else {
    Write-Host "Repository already exists. Pulling latest changes..."
    Set-Location -Path $RepoPath
    git pull
}

Write-Host "Importing NixOS into WSL..."
wsl.exe --import NixOS $NixOSFolder $NixOSImage

Write-Host "Setting NixOS as default WSL instance..."
wsl.exe -s NixOS

if (-Not (Test-Path -Path $VHDXPath)) {
    Write-Host "Creating VHDX file..."
    New-VHD -Path $VHDXPath -SizeBytes 20GB -Dynamic

    $formatDisk = "sudo mkfs.ext4 /mnt/c/wsl/nixos/home.vhdx"

    Write-Host "Formatting VHDX as ext4 inside NixOS..."
    wsl.exe -d NixOS -- bash -c $formatDisk
} else {
    Write-Host "VHDX already exists, skipping creation."
}

Write-Host "VHDX file formatted to ext4."
