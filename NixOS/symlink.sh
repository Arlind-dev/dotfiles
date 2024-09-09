#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo or as root."
  exit 1
fi

SOURCE_DIR="$HOME/.dotfiles/nix/NixOS"
TARGET_DIR="/etc/nixos"

mkdir -p $TARGET_DIR
mkdir -p $TARGET_DIR/modules/packages
mkdir -p $TARGET_DIR/modules/users
mkdir -p $TARGET_DIR/modules/virtualization

rm -rf $TARGET_DIR/*

ln -sf "$SOURCE_DIR/configuration.nix" "$TARGET_DIR/configuration.nix"
ln -sf "$SOURCE_DIR/flake.lock" "$TARGET_DIR/flake.lock"
ln -sf "$SOURCE_DIR/flake.nix" "$TARGET_DIR/flake.nix"

ln -sf "$SOURCE_DIR/modules/mynixos-options.nix" "$TARGET_DIR/modules/mynixos-options.nix"
ln -sf "$SOURCE_DIR/modules/networking.nix" "$TARGET_DIR/modules/networking.nix"
ln -sf "$SOURCE_DIR/modules/programs.nix" "$TARGET_DIR/modules/programs.nix"
ln -sf "$SOURCE_DIR/modules/system-services.nix" "$TARGET_DIR/modules/system-services.nix"

ln -sf "$SOURCE_DIR/modules/packages/database-clients.nix" "$TARGET_DIR/modules/packages/database-clients.nix"
ln -sf "$SOURCE_DIR/modules/packages/default.nix" "$TARGET_DIR/modules/packages/default.nix"
ln -sf "$SOURCE_DIR/modules/packages/desktop-applications.nix" "$TARGET_DIR/modules/packages/desktop-applications.nix"
ln -sf "$SOURCE_DIR/modules/packages/development-tools.nix" "$TARGET_DIR/modules/packages/development-tools.nix"
ln -sf "$SOURCE_DIR/modules/packages/utilities.nix" "$TARGET_DIR/modules/packages/utilities.nix"

ln -sf "$SOURCE_DIR/modules/users/nixos.nix" "$TARGET_DIR/modules/users/nixos.nix"
ln -sf "$SOURCE_DIR/modules/users/root.nix" "$TARGET_DIR/modules/users/root.nix"

ln -sf "$SOURCE_DIR/modules/virtualization/docker.nix" "$TARGET_DIR/modules/virtualization/docker.nix"
ln -sf "$SOURCE_DIR/modules/virtualization/helm.nix" "$TARGET_DIR/modules/virtualization/helm.nix"
ln -sf "$SOURCE_DIR/modules/virtualization/k3s.nix" "$TARGET_DIR/modules/virtualization/k3s.nix"
ln -sf "$SOURCE_DIR/modules/virtualization/podman.nix" "$TARGET_DIR/modules/virtualization/podman.nix"
