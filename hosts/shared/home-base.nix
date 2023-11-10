{lib, ...}:
# Home manager configs that are common to all setups
{
  # lf
  programs.lf.enable = true;
  xdg.configFile."lf/lfrc".source = ../../src/lf/lfrc;

  # starship
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };
  xdg.configFile."starship.toml".source = ../../src/starship/starship.toml;

  # Bash configuration
  home.file.".config/bash/git.sh".source = ../../src/bash/git.sh;
  home.file.".config/bash/parsely.sh".source = ../../src/bash/parsely.sh;
  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ../../src/bash/includes.sh;
    enableCompletion = true;
    initExtra = lib.mkAfter ''
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
