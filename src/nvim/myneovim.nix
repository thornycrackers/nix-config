{ pkgs, ... }:
# I keep this in a file simply to keep the top level flake a bit cleaner to read.
# Defines my neovim with it's config file, vim plugins, and all packages (such as language servers and linters)
let
  neovimOverride = pkgs.unstable.neovim.override {
    withPython3 = true;
    configure = {
      # customRC expects vimscript but I've already converted to lua
      customRC = ''
        lua << EOF
        ${pkgs.lib.readFile ./init.lua}
        dofile('${./lua/qfnotes.lua}')
        dofile('${./lua/utils.lua}')
        EOF
        let g:languagetool_server_command = '${pkgs.languagetool}/bin/languagetool-http-server'
      '';
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [
          # Colorscheme
          gruvbox-nvim

          # Syntax coloring
          rainbow-delimiters-nvim
          nvim-treesitter.withAllGrammars

          # Autocompletes
          nvim-lspconfig
          nvim-cmp
          cmp-nvim-lsp

          # File navigation
          lf-vim
          vim-floaterm

          # The rest
          plenary-nvim
          vim-commentary
          vim-surround
          vim-repeat
          fzf-vim
          fzf-lua
          telescope-nvim
          telescope-ui-select-nvim
          vim-argwrap
          vim-fugitive
          indent-blankline-nvim
          hop-nvim
          ale
          goyo-vim
          vim-oscyank
          ack-vim
          (pkgs.callPackage ./nix/vim-angry-reviewer.nix { })
          (pkgs.callPackage ./nix/vim-hmts.nix { })
          LanguageTool-nvim
          vim-table-mode
          vim-bufkill
          emmet-vim
          tagbar
          vim-markdown
          vim-go
          vim-fetch
          nvim-luadev
          mini-nvim
          (pkgs.callPackage ./nix/obsidian-nvim.nix { })
          # Octo and Deps
          octo-nvim
          nvim-web-devicons
        ];
      };
    };
  };
in
pkgs.symlinkJoin {
  name = "neovim";
  paths = [ neovimOverride ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild =
    with pkgs;
    let
      nvimPackages = import ./packages.nix pkgs;
    in
    ''
      rm $out/bin/nvim
      BINPATH=${lib.makeBinPath nvimPackages}
      makeWrapper ${neovimOverride}/bin/nvim $out/bin/nvim --suffix PATH : $BINPATH
    '';
}
