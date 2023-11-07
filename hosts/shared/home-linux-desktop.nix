{
  pkgs,
  inputs,
  username,
  homedirectory,
  ...
}: {
  imports = [./home-base.nix];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${username}";
  home.homeDirectory = "${homedirectory}";

  # Wrapper packages via wrapper-manager
  # There's no hard or fast rules for when to use home manager vs wrapper manager.
  # I guess the best heuristic is how much I want to customize in the tool?
  home.packages = [
    (inputs.wrapper-manager.lib.build {
      inherit pkgs;
      modules = [../../src/bat ../../src/tmux];
    })
  ];

  # TODO: This is just "whatever" for now, clean it up later
  xdg.configFile."i3/config".source = ../../src/i3/config;
  xdg.configFile."i3/scripts" = {
    source = ../../src/i3/scripts;
    recursive = true;
  };

  # Let home manager manage rofi.
  programs.rofi = {
    enable = true;
    pass = {
      enable = true;
      extraConfig = "help_color=\"#FA6607\"";
    };
    theme = "gruvbox-dark";
  };

  # I like the a very small amount of opacity
  services.picom = {
    enable = true;
    opacityRules = [
      "95:name = 'zsh'"
      "95:class_g = 'floating'"
      "95:class_g = 'emacs'"
      # Below hides windows in i3's tabbed mode. That way if I have my terminal over say, a browser,
      # I will see my desktop background and not the browser.
      "0:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[1]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[2]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[3]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[4]:32a = '_NET_WM_STATE_HIDDEN'"
    ];
  };

  services.clipmenu = {
    enable = true;
  };

  # kitty config
  xdg.configFile."kitty/kitty.conf".source = ../../src/kitty/kitty.conf;

  services.flameshot = {
    enable = true;
  };

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
