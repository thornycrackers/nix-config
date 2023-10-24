{ pkgs, ... }:

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
    initExtra = builtins.readFile ../../src/zsh/zshrc;
    plugins = with pkgs; [
      {
        name = "zsh-autosuggestions";
        file = "zsh-autosuggestions.zsh";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
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
        name = "zsh-history-substring-search";
        file = "zsh-history-substring-search.zsh";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "v1.1.0";
          sha256 = "GSEvgvgWi1rrsgikTzDXokHTROoyPRlU0FVpAoEmXG4=";
        };
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.7.0";
          sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
        };
      }
    ];
  };
  home.file.".config/zsh/git.zsh".source = ../../src/zsh/git.zsh;

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
