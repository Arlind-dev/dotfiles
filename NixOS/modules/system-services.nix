{ config, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_hardened;
  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.unprivileged_bpf_disabled" = 1;
  };

  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    settings = {
      PasswordAuthentication = true;
      UseDns = true;
      X11Forwarding = true;
      PermitRootLogin = "no";
    };
  };

  services.logrotate = {
    enable = true;
  };
}
