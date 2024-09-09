{ config, pkgs, lib, ... }:

let
  enableDesktopEnvironment = config.MyNixOS.packages.enableDesktopEnvironment or false;
in
{
  environment.systemPackages = lib.optionals enableDesktopEnvironment (with pkgs; [
    firefox
  ]);

  services = lib.mkIf enableDesktopEnvironment {
    xrdp = {
      enable = true;
      port = 3390;
      defaultWindowManager = "startplasma-x11";
      openFirewall = true;
    };

    xserver = {
      enable = true;
      desktopManager.plasma5.enable = true;
    };

    displayManager.sddm = {
      enable = true;
    };
  };
}
