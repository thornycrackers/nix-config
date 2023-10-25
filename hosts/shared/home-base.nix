{pkgs, ...}:
# Home manager configs that are common to all setups
{
  # lf
  programs.lf.enable = true;
  xdg.configFile."lf/lfrc".source = ../../src/lf/lfrc;

  # starship
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ../../src/starship/starship.toml;

  # zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    initExtra = builtins.readFile ../../src/zsh/zshrc;
    plugins = with pkgs; [
      {
        name = "zsh-syntax-highlighting";
        file = "zsh-syntax-highlighting.zsh";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
        };
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.7.0";
          sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
        };
      }
      # I create this plugin so that all my autocompletes are added to the zsh
      # fpath and I can use custom autocompletes in my functions
      {
        name = "myautocompletes";
        src = ../../src/zsh/autocompletes;
      }
      # I create this plugin so that all my custom shell binaries are on the path
      {
        name = "mybin";
        src = ../../src/zsh/bin;
      }
    ];
  };
  home.file.".config/zsh/git.zsh".source = ../../src/zsh/git.zsh;

  # colors for ls
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ../../src/zsh/ls_colors;
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
