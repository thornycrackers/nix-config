{
  lib,
  pkgs,
  ...
}:
# Home manager configs that are common to all setups
{
  # lf
  xdg.configFile."lf/lfrc".source = ../../src/lf/lfrc;

  # starship
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };
  xdg.configFile."starship.toml".source = ../../src/starship/starship.toml;

  # Bash configuration
  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ../../src/bash/includes.sh;
    enableCompletion = true;
    initExtra =
      lib.mkAfter
      /*
      bash
      */
      ''
        # Load autocomplete functions from git, used to provide autcompletes
        # to some of my aliases
        source ${pkgs.unstable.git}/share/bash-completion/completions/git
        # https://github.com/scop/bash-completion/issues/545
        # Complete for gco alias
        _comp_gco() {
          local __git_cmd_idx=0
          _git_checkout
        } && __git_complete gco _comp_gco
        # Direnv needs to be loaded just before ble.sh. If I leave it to home
        # manager then it will put direnv after blesh and it doesn't work.
        eval "$(direnv hook bash)"
        # Load BLE last
        [[ ''${BLE_VERSION-} ]] && ble-attach
      '';
  };
  home.file.".blerc".source = ../../src/blesh/blerc;
  # Add my custom bash scripts
  home.file.".config/bash/bin" = {
    source = ../../src/bash/bin;
    recursive = true;
  };
  home.file.".config/bash/scripts" = {
    source = ../../src/bash/scripts;
    recursive = true;
  };

  # colors for ls
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ../../src/bash/ls_colors;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # git config
  xdg.configFile."git/config".source = ../../src/git/config;

  # ack config
  home.file.".ackrc".source = ../../src/ack/ackrc;

  # lazgit config
  xdg.configFile."lazygit/config.yml".source = ../../src/lazygit/config.yml;
}
