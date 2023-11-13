{
  pkgs,
  wrapper-manager,
  flakePkgs,
  ...
}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-trusted-users = codyhiar
    '';
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; let
    basePackages = import ../../hosts/shared/packages-base.nix pkgs;
    darwinPackages = import ../../hosts/shared/packages-darwin.nix pkgs;
    parselyPackages = import ../../hosts/shared/packages-parsely.nix pkgs;
    localPackages = [
      flakePkgs.myneovim
      (wrapper-manager.lib.build {
        inherit pkgs;
        modules = [../../src/bat ../../src/tmux];
      })
    ];
  in
    lib.mkMerge [
      basePackages
      darwinPackages
      parselyPackages
      localPackages
    ];

  # Let nix run homebrew. This won't install homebrew visit:
  # https://brew.sh/ to get install info.
  homebrew = {
    enable = true;
    brews = ["choose-gui"];
    casks = [
      "firefox"
      "zoom"
      "karabiner-elements"
      "slack"
      "kitty"
      "rectangle"
      "utm"
      "font-dejavu-sans-mono-nerd-font"
      "docker"
      "raycast"
    ];
    taps = ["homebrew/cask-fonts"];
    onActivation.cleanup = "zap";
    masApps = {"Logic Pro" = 634148309;};
  };

  users.users.codyhiar = {
    # https://github.com/nix-community/home-manager/issues/4026
    home = "/Users/codyhiar";
    shell = pkgs.bashInteractive;
  };
  programs.bash.enable = true;
  # I had to manually run `chsh` to get the shell to change.
  environment.shells = [pkgs.bashInteractive];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Setup tailscale private network
  services.tailscale.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
