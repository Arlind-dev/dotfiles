{ config, pkgs, ... }:

{
  imports = [
    <nixos-wsl/modules>
    <home-manager/nixos>
  ];

  networking.firewall.enable = false;

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
    initialHashedPassword = "$y$j9T$SjzV54a2Dt6SD6kL9E4tn/$3tFQ4kBfJBSDELii/8QHzraCAqoiINNljzZcD7m4AS3"; # nixos
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
    defaultWindowManager = "startplasma-x11";
    openFirewall = true;
  };

  home-manager.users.nixos = {
    home.stateVersion = "24.11";
  };
}
