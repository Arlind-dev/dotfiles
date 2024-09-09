$NixOSFolder = "C:\wsl\nixos"
$NixOSImage = "$NixOSFolder\nixos-wsl.tar.gz"
$VHDXPath = "$NixOSFolder\home.vhdx"
$RepoURL = "https://github.com/Arlind-dev/dotfiles"
$RepoPath = "$NixOSFolder\dotfiles"
$NixFilesSource = "/mnt/c/wsl/nixos/dotfiles/NixOS"
$NixFilesDest = "/home/nixos/.dotfiles/nix"

$wslCheck = wsl.exe --version 2>$null

if (-Not $wslCheck) {
    wsl.exe --install --no-distribution
}

$wslInstances = wsl.exe -l -q
if ($wslInstances -contains "NixOS") {
    wsl.exe --unregister NixOS
}

if (-Not (Test-Path -Path $NixOSImage)) {
    if (-Not (Test-Path -Path $NixOSFolder)) {
        New-Item -Path $NixOSFolder -ItemType Directory
    }
    Invoke-WebRequest -Uri "https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos-wsl.tar.gz" -OutFile $NixOSImage
}

if (-Not (Test-Path -Path $RepoPath)) {
    git clone $RepoURL $RepoPath
} else {
    Set-Location -Path $RepoPath
    git pull
}

wsl.exe --import NixOS "$NixOSFolder" "$NixOSImage"

wsl.exe -s NixOS

if (-Not (Test-Path -Path $VHDXPath)) {
    New-VHD -Path $VHDXPath -SizeBytes 20GB -Dynamic

    $formatDisk = "sudo mkfs.ext4 /mnt/c/wsl/nixos/home.vhdx"
    wsl.exe -d NixOS -- bash -c $formatDisk
}

Write-Host "Copying NixOS configuration files to $NixFilesDest..."
wsl.exe -d NixOS -- bash -c "mkdir -p $NixFilesDest"
wsl.exe -d NixOS -- bash -c "cp -r $NixFilesSource/* $NixFilesDest"


Write-Host "Rebuild with flake in progress, this may take a few minutes...."
wsl.exe -d NixOS -- bash -c "sudo nixos-rebuild switch --flake ~/.dotfiles/nix"

wsl.exe --shutdown

wsl.exe -d NixOS -- bash -c "sudo nixos-rebuild switch --flake ~/.dotfiles/nix"

Write-Host "Setup complete."
