#!/usr/bin/env bash

SOURCE_DIR="/home/nixos/.dotfiles/nix/NixOS"
TARGET_DIR="/etc/nixos"

sudo mkdir -p $TARGET_DIR
sudo mkdir -p $TARGET_DIR/modules
sudo mkdir -p $TARGET_DIR/modules/packages
sudo mkdir -p $TARGET_DIR/modules/users
sudo mkdir -p $TARGET_DIR/modules/virtualization

sudo ln -sf "$SOURCE_DIR/configuration.nix" "$TARGET_DIR/configuration.nix"
sudo ln -sf "$SOURCE_DIR/flake.lock" "$TARGET_DIR/flake.lock"
sudo ln -sf "$SOURCE_DIR/flake.nix" "$TARGET_DIR/flake.nix"

sudo ln -sf "$SOURCE_DIR/modules/mynixos-options.nix" "$TARGET_DIR/modules/mynixos-options.nix"
sudo ln -sf "$SOURCE_DIR/modules/networking.nix" "$TARGET_DIR/modules/networking.nix"
sudo ln -sf "$SOURCE_DIR/modules/programs.nix" "$TARGET_DIR/modules/programs.nix"
sudo ln -sf "$SOURCE_DIR/modules/system-services.nix" "$TARGET_DIR/modules/system-services.nix"

sudo ln -sf "$SOURCE_DIR/modules/packages/database-clients.nix" "$TARGET_DIR/modules/packages/database-clients.nix"
sudo ln -sf "$SOURCE_DIR/modules/packages/default.nix" "$TARGET_DIR/modules/packages/default.nix"
sudo ln -sf "$SOURCE_DIR/modules/packages/desktop-applications.nix" "$TARGET_DIR/modules/packages/desktop-applications.nix"
sudo ln -sf "$SOURCE_DIR/modules/packages/development-tools.nix" "$TARGET_DIR/modules/packages/development-tools.nix"
sudo ln -sf "$SOURCE_DIR/modules/packages/utilities.nix" "$TARGET_DIR/modules/packages/utilities.nix"

sudo ln -sf "$SOURCE_DIR/modules/users/nixos.nix" "$TARGET_DIR/modules/users/nixos.nix"
sudo ln -sf "$SOURCE_DIR/modules/users/root.nix" "$TARGET_DIR/modules/users/root.nix"

sudo ln -sf "$SOURCE_DIR/modules/virtualization/docker.nix" "$TARGET_DIR/modules/virtualization/docker.nix"
sudo ln -sf "$SOURCE_DIR/modules/virtualization/helm.nix" "$TARGET_DIR/modules/virtualization/helm.nix"
sudo ln -sf "$SOURCE_DIR/modules/virtualization/k3s.nix" "$TARGET_DIR/modules/virtualization/k3s.nix"
sudo ln -sf "$SOURCE_DIR/modules/virtualization/podman.nix" "$TARGET_DIR/modules/virtualization/podman.nix"
