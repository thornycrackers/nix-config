pkgs:
with pkgs;
let
  vale = pkgs.callPackage ./nix/vale.nix { };
  flake8-isort = pkgs.python3Packages.callPackage ./nix/nvimpython.nix {
    flake8-isort = pkgs.python3Packages.callPackage ./nix/flake8-isort.nix { };
  };
  my-lua = unstable.lua5_1.withPackages (ps: with ps; [ busted ]);
in
[
  my-lua
  ack
  unstable.nixfmt-rfc-style
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
  # Want at least version 31 for dupfilefmt
  unstable.lf
  nil
  nodePackages.bash-language-server
  luaformatter
  nodejs
  pyright
  ruff
  isort
  shellcheck
  shfmt
  terraform-ls
  tree-sitter
  vale
]
