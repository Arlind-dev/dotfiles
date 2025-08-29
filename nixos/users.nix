{ inputs, pkgs, ... }:

{
  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    initialPassword = "correcthorsebatterystaple";
    openssh.authorizedKeys.keys = [ ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.nixos = import ../home-manager/home.nix;
  };
}
