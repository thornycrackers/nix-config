{ ... }: {
  imports = [ ./home-base.nix ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.homeDirectory = "/Users/codyhiar";

  # kitty config
  xdg.configFile."kitty/kitty.conf".source = ../../src/kitty/kitty.conf;

  # tridactyl config
  xdg.configFile."tridactyl/tridactylrc".source =
    ../../src/tridactyl/tridactylrc;

  # karabiner configs
  xdg.configFile."karabiner" = {
    source = ../../src/karabiner;
    recursive = true;
  };

  xdg.configFile."raycast" = {
    source = ../../src/raycast;
    recursive = true;
  };

  # NOTE: On darwin the home.packages doesn't seem to link properly. Not sure
  # why but I just add packages into darwin-configuration.nix instead. I leave
  # this note as a reminder.
  # home.packages = [ ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
