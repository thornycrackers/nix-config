{
  pkgs,
  wrapper-manager,
  flakePkgs,
  ...
}:
{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # I'm not sure why, but LANG is never set on this host and it messes with the
  # nerdfont symbols.
  environment.variables = {
    LANG = "en_CA.UTF-8";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    with pkgs;
    let
      basePackages = import ../../hosts/shared/packages-base.nix pkgs;
      darwinPackages = import ../../hosts/shared/packages-darwin.nix pkgs;
      parselyPackages = import ../../hosts/shared/packages-parsely.nix pkgs;
      localPackages = [
        flakePkgs.myneovim
        (wrapper-manager.lib.build {
          inherit pkgs;
          modules = [
            ../../src/bat
            {
              # Instead of using the shared module for tmux, I build my own here
              # as a hackey work around for adding tmux config overrides. It
              # seems to be working for now, but I'm sure there's a cleaner
              # solution to doing this.
              wrappers.tmux =
                let
                  tmuxConf = builtins.readFile ../../src/tmux/tmux.conf;
                  tmuxOverrides = builtins.readFile ../../src/tmux/tmux-darwin-overrides.conf;
                  darwinTmuxConf = lib.concatStringsSep "\n" [
                    tmuxConf
                    tmuxOverrides
                  ];
                  fileLocation = pkgs.writeText "tmuxdarwinconfig" darwinTmuxConf;
                in
                {
                  basePackage = pkgs.tmux;
                  flags = [ "-f ${fileLocation}" ];
                  pathAdd = [
                    (pkgs.writeShellScriptBin "rolodex.sh" (builtins.readFile ../../src/tmux/rolodex.sh))
                    (pkgs.writeShellScriptBin "tmux_switch_session.sh" (
                      builtins.readFile ../../src/tmux/tmux_switch_sessions.sh
                    ))
                  ];
                };
            }
          ];
        })
        (pass.withExtensions (ext: with ext; [ pass-otp ]))
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
    brews = [ "choose-gui" ];
    casks = [
      "blackhole-2ch"
      "obs"
      "vlc"
      "openshot-video-editor"
      "google-chrome"
      "firefox"
      "zoom"
      "karabiner-elements"
      "slack"
      "kitty"
      "rectangle"
      "utm"
      "font-dejavu-sans-mono-nerd-font"
      "raycast"
      "obsidian"
      "discord"
      "whatsapp"
      "signal"
    ];
    onActivation.cleanup = "zap";
  };

  users.users.codyhiar = {
    # https://github.com/nix-community/home-manager/issues/4026
    home = "/Users/codyhiar";
    shell = pkgs.bashInteractive;
  };
  programs.bash.enable = true;
  # I had to manually run `chsh` to get the shell to change.
  environment.shells = [ pkgs.bashInteractive ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Setup tailscale private network
  services.tailscale.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
