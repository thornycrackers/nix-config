pkgs:
with pkgs; let
  vale = pkgs.callPackage ./nix/vale.nix {};
  flake8-isort = pkgs.python3Packages.callPackage ./nix/nvimpython.nix {
    flake8-isort =
      pkgs.python3Packages.callPackage ./nix/flake8-isort.nix {};
  };
in [
  alejandra
  ansible
  ansible-language-server
  ansible-lint
  ctags
  flake8-isort
  gcc
  go
  gotools
  hadolint
  languagetool
  lf
  nil
  nodePackages.bash-language-server
  nodejs
  pyright
  ruff
  shellcheck
  shfmt
  terraform-ls
  tree-sitter
  vale
]
