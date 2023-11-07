pkgs:
with pkgs; [
  ctags
  gcc
  nodejs
  (pkgs.python3Packages.callPackage ./nix/nvimpython.nix {
    flake8-isort =
      pkgs.python3Packages.callPackage ./nix/flake8-isort.nix {};
  })
  (pkgs.callPackage ./nix/vale.nix {})
  pyright
  tree-sitter
  nodePackages.bash-language-server
  shellcheck
  shfmt
  hadolint
  languagetool
  lf
  terraform-ls
  ansible-language-server
  ansible-lint
  ansible
  go
  gotools
  nil
  alejandra
]
