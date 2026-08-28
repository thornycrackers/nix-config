pkgs:
with pkgs;
let
  vale = pkgs.callPackage ./nix/vale.nix { };
  my-lua = unstable.lua5_1.withPackages (ps: with ps; [ busted ]);
in
[
  my-lua
  ack
  unstable.nixfmt
  ctags
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
  mdformat
  nodejs
  pyright
  ripgrep
  ruff
  isort
  shellcheck
  shfmt
  tree-sitter
  vale
]
