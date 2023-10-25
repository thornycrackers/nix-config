{
  python3,
  flake8-isort,
}:
# I want neovim to have a base install for python linting so I create this custom python
let
  nvimpython-packages = python-packages:
    with python-packages; [
      jedi-language-server
      flake8
      flake8-isort
      isort
      black
    ];
  nvimpython = python3.withPackages nvimpython-packages;
in
  nvimpython
