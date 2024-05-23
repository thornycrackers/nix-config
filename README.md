# My Nix Config Monorepo

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/thornycrackers/nix-config/main.yml)
![GitHub last commit](https://img.shields.io/github/last-commit/thornycrackers/nix-config)

At first, this repo was for storing config between linux/darwin machines in the `hosts`.
Then I added `home-manager` and started adding all my dotfiles in the `src`.
Then I decided to export my `tmux` and `neovim` setups.

```bash
# Run my tmux setup
nix run github:thornycrackers/nix-config#mytmux
# Run my neovim setup with everything installed
nix run github:thornycrackers/nix-config#myneovim
```

Then I wanted a place to for toy projects so I created the `playground` directory.
Projects in that directory re-use functions and packages from the root flake which helps cut down setup time.
