{ config, pkgs, ... }:

let
  my-kubernetes-helm = with pkgs; wrapHelm kubernetes-helm {
    plugins = with pkgs.kubernetes-helmPlugins; [
      helm-secrets
      helm-diff
      helm-s3
      helm-git
    ];
  };

  my-helmfile = pkgs.helmfile-wrapped.override {
    inherit (my-kubernetes-helm) pluginsDir;
  };
in

{
  imports = [
    <nixos-wsl/modules>
    <home-manager/nixos>
  ];

  boot.kernelPackages = pkgs.linuxPackages_hardened;
  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.unprivileged_bpf_disabled" = 1;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 2222 3390 6443 ];
    allowedUDPPorts = [ ];
  };

  system.stateVersion = "24.11";

  system.autoUpgrade.enable = true;

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.dates = "daily";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANG = "en_US.UTF-8";
  };
  time.timeZone = "Europe/Zurich";

  users.users.nixos = {
    isNormalUser = true;
    home = "/home/nixos";
    shell = pkgs.zsh;
    extraGroups = [ "docker" ];
  };

  users.users.root = {
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    gcc
    glibc
    binutils
    gnumake
    cmake
    tree
    unzip
    ripgrep
    ctop
    htop
    fastfetch
    wget
    tcpdump
    python3
    python3Packages.pip
    nodejs
    nodePackages.npm
    bat
    mysql-client
    postgresql
    sqlite
    docker-compose
    podman-compose
    podman-tui
    my-kubernetes-helm
    my-helmfile
    firefox
  ];

  environment.variables = {
    EDITOR = "nvim";
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  virtualisation.containers.enable = true;

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      "d" = "docker $*";
      "d-c" = "docker compose $*";
      "update" = "sudo nixos-rebuild switch";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git"];
      theme = "alanpeabody";
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  programs.git = {
    enable = true;
  };

  programs.nano = {
    enable = false;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--write-kubeconfig-mode=0644"
    ];
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

  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
  };

  services.xrdp = {
    enable = true;
    port = 3390;
    defaultWindowManager = "startplasma-x11";
    openFirewall = true;
  };

  home-manager.users.nixos = {
    home.stateVersion = "24.11";
  };

  home-manager.users.root = {
    home.stateVersion = "24.11";
  };
}
