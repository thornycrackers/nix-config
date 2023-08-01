{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "thorny";
  home.homeDirectory = "/home/thorny";

  # lf
  programs.lf.enable = true;
  xdg.configFile."lf/lfrc".source = ./src/lf/lfrc;

  # starship
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./src/starship/starship.toml;

  # zsh
  programs.zsh.enable = true;
  programs.zsh.initExtra = builtins.readFile ./src/zsh/zshrc;

  # tmux
  programs.tmux.enable = true;
  xdg.configFile."tmux/tmux.conf".source = ./src/tmux/tmux.conf;

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
