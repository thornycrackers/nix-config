{ config, pkgs, wrapper-manager, flakePkgs, ... }:

{

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-trusted-users = codyhiar
    '';
  };

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    flakePkgs.myneovim
    unstable.gitAndTools.delta
    git
    btop
    htop
    # Need up to date ncurses or colors inside of tmux get wonky
    coreutils
    ncurses
    openvpn
    wget
    # Packages that won't install inside home.nix
    lf
    fzf
    nixos-rebuild
    docker-compose
    lazydocker
    lazygit
    ack
    (wrapper-manager.lib.build {
      inherit pkgs;
      modules = [ ../../src/bat ../../src/tmux ];
    })
  ];

  # Let nix run homebrew. This won't install homebrew visit:
  # https://brew.sh/ to get install info.
  homebrew = {
    enable = true;
    casks = [
      "google-chrome"
      "zoom"
      "karabiner-elements"
      "slack"
      "kitty"
      "rectangle"
      "utm"
      "font-dejavu-sans-mono-nerd-font"
      "docker"
    ];
    taps = [ "homebrew/cask-fonts" ];
    onActivation.cleanup = "zap";
  };

  # https://github.com/nix-community/home-manager/issues/4026
  users.users.codyhiar.home = "/Users/codyhiar";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
