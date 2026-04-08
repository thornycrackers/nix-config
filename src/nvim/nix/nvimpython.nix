{ python }:
# I want neovim to have a base install for python linting so I create this custom python
let
  nvimpython-packages =
    ps: with ps; [
      jedi-language-server
      flake8
      isort
      black
    ];
  nvimpython = python.withPackages nvimpython-packages;
in
nvimpython
