{ pkgs, ... }:

# I keep this in a file simply to keep the top level flake a bit cleaner to read.
# This defines the configuration

(pkgs.neovim.override {
  configure = {
    # customRC expects vimscript but I've already converted to lua
    customRC = ''
      lua << EOF
      ${pkgs.lib.readFile ./init.lua}
      EOF
      " lua doesn't like the special characters
      let g:languagetool_server_command = '${pkgs.languagetool}/bin/languagetool-http-server'
    '';
    packages.myPlugins = with pkgs.vimPlugins; {
      start = [
        # Colorscheme
        gruvbox-nvim

        # Syntax coloring
        nvim-ts-rainbow
        nvim-treesitter.withAllGrammars

        # Autocompletes
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp

        # File navigation
        lf-vim
        vim-floaterm

        # The rest
        vim-commentary
        vim-surround
        vim-repeat
        fzf-vim
        vim-argwrap
        vim-fugitive
        indent-blankline-nvim
        camelcasemotion
        hop-nvim
        ale
        goyo-vim
        vim-oscyank
        ack-vim
        (pkgs.callPackage ./nix/vim-angry-reviewer.nix { })
        LanguageTool-nvim
        camelcasemotion
        vim-table-mode
        vim-bufkill
        emmet-vim
        tagbar
        vim-markdown
        vim-go
      ];
    };
  };
})
