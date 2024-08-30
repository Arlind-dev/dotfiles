{ config, pkgs, ... }:

{
  imports = [
    <nixos-wsl/modules>
    <home-manager/nixos>
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 3390 6443 ];
    allowedUDPPorts = [ ]
  };

  system.stateVersion = "24.11";

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
  ];

  environment.variables.EDITOR = "nvim";

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

  services.k3s.enable = true;
  services.k3s.role = "server";

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      UseDns = true;
      X11Forwarding = true;
      PermitRootLogin = "no";
    };
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
