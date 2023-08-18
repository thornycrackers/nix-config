{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.homeDirectory = pkgs.lib.mkForce "/Users/codyhiar";

  # lf
  programs.lf.enable = true;
  xdg.configFile."lf/lfrc".source = ../../src/lf/lfrc;

  # starship
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ../../src/starship/starship.toml;

  # zsh
  programs.zsh.enable = true;
  programs.zsh.initExtra = builtins.readFile ../../src/zsh/zshrc;
  home.file.".config/zsh/git.zsh".source = ../../src/zsh/git.zsh;

  # git config
  xdg.configFile."git/config".source = ../../src/git/config;

  # Wrapper packages via wrapper-manager
  # There's no hard or fast rules for when to use home manager vs wrapper manager.
  # I guess the best heuristic is how much I want to customize in the tool?
  home.packages = [
    pkgs.fzf
    (inputs.wrapper-manager.lib.build {
      inherit pkgs;
      modules = [ ../../src/bat ../../src/tmux ];
    })
  ];

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
