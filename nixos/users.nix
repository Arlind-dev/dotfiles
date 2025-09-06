{ inputs, pkgs, ... }:

{
  users.users.arlind = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    initialPassword = "correcthorsebatterystaple";
    openssh.authorizedKeys.keys = [ ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.arlind = import ../home-manager/default.nix;
  };
}
