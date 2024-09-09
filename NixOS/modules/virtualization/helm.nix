{ config, pkgs, lib, ... }:

let
  enableK3s = config.MyNixOS.virtualization.enableK3s or false;
  enableHelm = config.MyNixOS.virtualization.enableHelm or false;

  my-kubernetes-helm = with pkgs; wrapHelm pkgs.kubernetes-helm {
    plugins = with pkgs.kubernetes-helmPlugins; [
      helm-secrets
      helm-diff
      helm-s3
      helm-git
    ];
  };

  my-helmfile = with pkgs; pkgs.helmfile-wrapped.override {
    inherit (my-kubernetes-helm) pluginsDir;
  };

in
{
  # Helm is only enabled if K3s is enabled
  environment.systemPackages = lib.optionals (enableK3s && enableHelm) (with pkgs; [
    my-kubernetes-helm
    my-helmfile
  ]);
}
