# My Nix Configs

My flake based Nix configs shared between my linux and darwin machines.
Each of the systems can be found in `hosts`.
The `src` folder contains all of the source files for my dotfiles.
I also expose wrapped versions of my tools as apps.
For example, if you clone the repo you can run my tmux with:

```
$ nix run .#mytmux
```
