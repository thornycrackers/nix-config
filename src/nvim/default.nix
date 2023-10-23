{ pkgs, ... }: {
  wrappers.neovim = {
    basePackage = (pkgs.neovim.override {
      configure = {
        customRC = ''
          lua << EOF
          ${pkgs.lib.readFile ./init.lua}
          EOF
          " lua doesn't like the special characters
          nnoremap <leader>pl vipJV:s/[.!?]  */&
/g
:noh
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
    });
    flags = [ "-u ${./init.lua}" ];
    # NOTE: extraPackages does not include all packages that I used with
    # neovim. For example, `lf` is not installed here, it's installed on the
    # host instead. If I add `lf` here, I get a name collision.
    extraPackages = with pkgs; [
      ctags
      gcc
      nodejs
      (pkgs.python3Packages.callPackage ./nix/nvimpython.nix {
        flake8-isort =
          (pkgs.python3Packages.callPackage ./nix/flake8-isort.nix { });
      })
      (pkgs.callPackage ./nix/vale.nix { })
      pyright
      tree-sitter
      nodePackages.bash-language-server
      shellcheck
      hadolint
      nixfmt
      languagetool
      terraform-ls
      ansible-language-server
      ansible-lint
      ansible
      go
      gotools
    ];
  };
}
