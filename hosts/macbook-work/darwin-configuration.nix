{ config, pkgs, wrapper-manager, ... }:

{

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neovimchpkgs.neovimCH
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
    (wrapper-manager.lib.build {
      inherit pkgs;
      modules = [ ../../src/bat ../../src/tmux ];
    })
    # Gui Apps
    kitty
    karabiner-elements
    slack
  ];

  # Let nix run homebrew. This won't install homebrew visit:
  # https://brew.sh/ to get install info.
  homebrew = {
    enable = true;
    casks = [ "google-chrome" "zoom" ];
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
