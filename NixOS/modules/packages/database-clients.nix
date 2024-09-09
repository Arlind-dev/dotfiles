{ config, pkgs, lib, ... }:

let
  enableDatabaseClients = config.MyNixOS.packages.enableDatabaseClients or false;
in
{
  environment.systemPackages = lib.optionals enableDatabaseClients (with pkgs; [
    mysql-client
    postgresql
    sqlite
  ]);
}
