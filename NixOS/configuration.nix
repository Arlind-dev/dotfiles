{ config, pkgs, ... }:

{
  imports = [
    <nixos-wsl/modules>
    <home-manager/nixos>
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 3390 ];
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
    home = "/mnt/wsl/home"; # shared home directory
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
  ];

  environment.variables.EDITOR = "nvim";

  virtualisation.docker.enable = true;

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

  systemd.services.createHomeDir = {
    description = "Create /mnt/wsl/home directory if it doesn't exist";
    after = [ "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c ''\
        if [ ! -d /mnt/wsl/home ]; then \
          mkdir -p /mnt/wsl/home && \
          chown nixos:nixos /mnt/wsl/home; \
        fi''";
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };

  systemd.services.deleteHomeDir = {
    description = "Delete /home/nixos directory if it exists";
    after = [ "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c ''\
        if [ -d /home/nixos ]; then \
          rm -rf /home/nixos; \
        fi''";
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };

  home-manager.users.nixos = {
    home.stateVersion = "24.11";
  };

  home-manager.users.root = {
    home.stateVersion = "24.11";
  };
}
