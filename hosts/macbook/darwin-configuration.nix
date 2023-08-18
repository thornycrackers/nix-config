{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neovimchpkgs.neovimCH
    btop
    htop
    # Need up to date ncurses or colors inside of tmux get wonky
    coreutils
    ncurses
    openvpn
    wget
  ];
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      # Took the config from determinate system's installer and brought it here

      # Generated by https://github.com/DeterminateSystems/nix-installer, version 0.8.0.
      build-users-group = nixbld
      extra-nix-path = nixpkgs=flake:nixpkgs
      auto-optimise-store = true
      bash-prompt-prefix = (nix:$name)\040
      experimental-features = nix-command flakes



      keep-outputs = true
      keep-derivations = true
      # Stuff for linux-builder (not currently used)
      # - Replace $ARCH with either aarch64 or x86_64 to match your host machine
      # - Replace $MAX_JOBS with the maximum number of builds (pick 4 if you're not sure)
      # builders = ssh-ng://builder@linux-builder x86_64-linux /etc/nix/builder_ed25519 4 - - - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=
      # Not strictly necessary, but this will reduce your disk utilization
      # builders-use-substitutes = true
    '';
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # The first time I tried installing nix-darwin after installing nix via
  # indeterminate installer's nix installer, it failed. I commented out the nix
  # daemon service above because I think I've already got it. The installation
  # of darwin failed and said I needed to add the line above or the one below
  # so I'm testing with this to see if that will make it play nice with the nix
  # installer
  nix.useDaemon = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}