-- Managed by Nix
--

-- https://dev.to/voyeg3r/writing-useful-lua-functions-to-my-neovim-14ki
-- function to remove whitespace and preserve spot on save
function _G.preserve(cmd)
    cmd = string.format('keepjumps keeppatterns execute %q', cmd)
    local original_cursor = vim.fn.winsaveview()
    vim.api.nvim_command(cmd)
    vim.fn.winrestview(original_cursor)
end
vim.cmd([[autocmd BufWritePre,FileWritePre,FileAppendPre,FilterWritePre * :lua preserve('%s/\\s\\+$//ge')]])


-- Debug function for printing lua tables
function _G.print_table(mytable)
    for k,v in pairs(mytable) do
        if (type(v) == "table") then
            print(k)
            print_table(v)
        else
            print(k, v)
        end
    end
end


-- Set up spacebar as leader
-- https://icyphox.sh/blog/nvim-lua/
vim.api.nvim_set_keymap('n', '<Space>', '', {})
vim.g.mapleader = ' '
-- Set spaces > tabs, 4 as default
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.cmd [[
autocmd Filetype nix setlocal ts=2 sw=2 sts=0 expandtab
autocmd Filetype terraform setlocal ts=2 sw=2 sts=0 expandtab
autocmd Filetype hcl setlocal ts=2 sw=2 sts=0 expandtab
autocmd Filetype html setlocal ts=2 sw=2 sts=0 expandtab
autocmd Filetype htmldjango setlocal ts=2 sw=2 sts=0 expandtab
autocmd BufNewFile,BufRead *.nomad setfiletype hcl
autocmd BufNewFile,BufRead *.yaml setfiletype yaml.ansible
autocmd BufNewFile,BufRead *.yml setfiletype yaml.ansible
autocmd BufNewFile,BufRead *.tfvars setfiletype terraform
]]
-- https://github.com/neovim/nvim-lspconfig/issues/2685#issuecomment-1623575758
-- ^ for the tfvars to terraform above
vim.o.relativenumber = true
-- Distable word wrap
vim.o.wrap = false
vim.o.history = 1000
-- Wildmode show list, complete to first result
vim.o.wildignore = "*/app/cache,*/vendor,*/env,*.pyc,*/venv,*/__pycache__,*/venv"
-- Default split directions
vim.o.splitright = true
vim.o.splitbelow = true
-- set spelling language
vim.o.spelllang = "en_ca"
-- Allow hidden buffers, no complain about saved work when switching
vim.o.hidden = true
-- Ask confirm on exit instead of error
vim.o.confirm = true
-- If a filetype has folding enabled, make sure all folds are opened
vim.o.foldlevel=99

-- My Highlights
vim.cmd [[
au VimEnter * hi Search ctermfg=166
au VimEnter * hi DiffAdd    cterm=BOLD ctermfg=NONE ctermbg=22
au VimEnter * hi DiffDelete cterm=BOLD ctermfg=NONE ctermbg=52
au VimEnter * hi DiffChange cterm=BOLD ctermfg=NONE ctermbg=23
au VimEnter * hi DiffText   cterm=BOLD ctermfg=NONE ctermbg=23
au VimEnter * hi Normal guibg=NONE ctermbg=NONE
au VimEnter * hi Search ctermbg=None ctermfg=166
au VimEnter * hi PrimaryBlock   ctermfg=06 ctermbg=NONE
au VimEnter * hi SecondaryBlock ctermfg=06 ctermbg=NONE
au VimEnter * hi Blanks   ctermfg=07 ctermbg=NONE
au VimEnter * hi ColorColumn ctermbg=cyan
au VimEnter * hi IndentBlanklineIndent1 ctermbg=234 ctermfg=NONE
au VimEnter * hi IndentBlanklineIndent2 ctermbg=235 ctermfg=NONE

function! s:goyo_leave()
hi NonText ctermbg=none
hi Normal guibg=NONE ctermbg=NONE
endfunction
autocmd! User GoyoLeave call <SID>goyo_leave()
]]

-- Along with the highlight definition for ColorColumn above, these options
-- will set colored marks at certain line lengths
vim.cmd [[
au BufEnter *.py let w:m1=matchadd('ColorColumn', '\%81v', 100)
au BufEnter *.py let w:m2=matchadd('Error', '\%121v', 100)
au BufLeave *.py call clearmatches()
]]

-- Custom commands
vim.cmd [[
command! MakeTagsPython !ctags --exclude=venv --exclude=.venv --languages=python --python-kinds=-i -R .
]]


-- Keymaps
--noh gets rid of highlighted search results
vim.api.nvim_set_keymap('n', '<leader><leader>', ':noh<cr>', { noremap = true })
-- `jj` maps to escape
vim.api.nvim_set_keymap('i', 'jj', '<esc>', { noremap = true })
-- Visually select last copied text
vim.api.nvim_set_keymap('n', 'gp', "`[v`]", { noremap = true })
-- Changelist navigation
vim.api.nvim_set_keymap('n', '<leader>co', '<cmd>copen<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>cc', '<cmd>cclose<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>cp', "<cmd>cprev<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>cn', "<cmd>cnext<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>lp', "<cmd>lprev<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ln', "<cmd>lnext<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>lo', "<cmd>lopen<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>lc', "<cmd>lclose<cr>", { noremap = true })
-- Shorcut to insert pudb statements for python
vim.api.nvim_set_keymap('n', '<leader>epu', 'ofrom pudb import set_trace; set_trace()<esc>', { noremap = true })
-- Shorcut to embed ipython
vim.api.nvim_set_keymap('n', '<leader>epi', 'ofrom IPython import embed<cr>from traitlets.config import get_config<cr>c = get_config()<cr>c.InteractiveShellEmbed.colors = "Linux"<cr>embed(config=c)<esc>', { noremap = true })
-- yank current word and make print statement on next line
vim.api.nvim_set_keymap('n', '<leader>epp', 'yiwoprint("<esc>pa: ", <esc>pa)<esc>V=', { noremap = true })
-- Easy new tab creation
vim.api.nvim_set_keymap('n', '<c-w>t', "<cmd>tabnew<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<c-w><c-f>', '<c-w>f<c-w>T', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-w><c-]>', '<c-w>v<c-]><c-w>T', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-w><c-t>', '<c-w>v<c-w>T', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-w><c-w>', '<cmd>w<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-w><c-a>', '<cmd>wa<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-q><c-a>', '<cmd>qa!<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ee', '<cmd>e!<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<expr> k', [[(v:count > 1 ? "m'" . v:count : '') . 'k']], { noremap = true })
vim.api.nvim_set_keymap('n', '<expr> j', [[(v:count > 1 ? "m'" . v:count : '') . 'j']], { noremap = true })
-- Call Ale Fix
vim.api.nvim_set_keymap('n', '<leader>ef', '<cmd>ALEFix<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>el', '<cmd>ALELint<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>et', '<cmd>lua toggle_ale_linting()<cr>', { noremap = true })
-- Markdown functions
vim.api.nvim_set_keymap('n', '<leader>po', '<cmd>AngryReviewer<cr><c-w>k<cmd>ALELint<cr><cmd>lopen<cr><c-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>pse', '<cmd>LanguageToolSetUp<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>psc', '<cmd>LanguageToolCheck<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>psu', '<cmd>LanguageToolSummary<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>psl', '<cmd>LanguageToolClear<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>pc', '<cmd>cclose<cr><cmd>lclose<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>pg', '<cmd>Goyo<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>pp', 'vipJVgq', { noremap = true })
-- Add "il" text object to mean "in line"
vim.api.nvim_set_keymap('x', 'il', 'g_o^', { noremap = true })
vim.api.nvim_set_keymap('o', 'il', '<cmd>normal vil<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>v', '^vg_o^', { noremap = true })

-- Build a custom status line
local status_line = {
    '%#PrimaryBlock#',
    '%#SecondaryBlock#',
    '%#Blanks#',
    '%f',
    '%m',
    '%=',
    '%#SecondaryBlock#',
    '%l,%c ',
    '%#PrimaryBlock#',
    '%{&filetype}',
}
vim.o.statusline = table.concat(status_line)

-- Options for all my plugins. Plugins are already installed via nix.

-- nord-vim
vim.cmd [[
colorscheme gruvbox
]]

-- nvim-ts-rainbow
-- nvim-treesitter
require('nvim-treesitter.configs').setup {
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
    },
    rainbow = {
        enable = true,
        -- I use termcolors but this errors if left blank
    }
}

-- nvim-lspconfig
-- nvim-cmp
-- cmp-nvim-lsp
nvim_lsp = require('lspconfig')
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
    -- Mappings.
    local opts = { noremap=true, silent=true }
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<spnce>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- local servers = { 'pyls', 'rust_analyzer', 'tsserver' }
local servers = { 'jedi_language_server', 'bashls', 'terraformls', 'ansiblels' }
-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
-- Setup language servers
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150,
        },
        capabilities = capabilities,
    }
end
-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'
-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-k>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
  },
}

-- nvim-fzf
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>let g:fzf_buffers_jump = 0<cr><cmd>Buffers<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ft', "<cmd>Tags<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fm', "<cmd>Marks<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>GF?<cr>", { noremap = true })
vim.cmd([[let $FZF_DEFAULT_COMMAND = 'find . -type f -not -path "*/\.git/*" -not -path "*/\.mypy_cache/*" -not -path "*/\.venv/*" -not -path "*/\node_modules/*" ']])
vim.cmd([[
nnoremap <leader>ff :call FilesDefault()<cr>
function! FilesDefault()
    if exists('g:fzf_action')
        " I don't set fzf_action except for the FilesNew thing so unset it for
        " default behaviour in files
        unlet g:fzf_action
    endif
    execute 'Files'
endfunction
nnoremap <leader>fn :let g:fzf_action = { 'enter': 'tab split' }<cr>:Files<cr>
nnoremap <leader>fo :call BufferTabJump()<CR>
function! BufferTabJump()
  let g:fzf_buffers_jump = 1
  execute 'Buffers'
endfunction
]])

-- vim-argwrap
vim.api.nvim_set_keymap('n', '<leader>ew', '<cmd>ArgWrap<cr>', { noremap = true })

-- vim-fugitive
vim.api.nvim_set_keymap('n', '<leader>du', '<cmd>diffupdate<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dd', '<cmd>diffget<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>df', '<cmd>diffput<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dc', ']c', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>de', '[c', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>gs', '<cmd>Git<cr>', { noremap = true })
vim.cmd([[
  function! ToggleGStatus()
    if buflisted(bufname('.git/index'))
      bd .git/index
    else
      G
      res 15
    endif
  endfunction
  nnoremap <leader>gs :call ToggleGStatus()<CR>
]])
vim.api.nvim_set_keymap('n', '<leader>gb', '<cmd>Git blame<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>gd', '<cmd>Gdiffsplit<cr>', { noremap = true })

-- indent-blankline-nvim
require("indent_blankline").setup {
    char = " ",
    char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    show_trailing_blankline_indent = false,
}

-- lf-vim
-- vim-floaterm
vim.g.floaterm_opener = "edit"
vim.g.floaterm_width = 0.99
vim.g.floaterm_height = 0.99
vim.api.nvim_set_keymap('n', '<leader>m', '<cmd>Lf<cr>', { noremap = true });
vim.api.nvim_set_keymap('n', '<leader>n', '<cmd>LfWorkingDirectory<cr>', { noremap = true});

--hop-nvim
vim.api.nvim_set_keymap('', '<leader>s', '<cmd>HopChar2<cr>', { noremap = true })
require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }

-- ale
vim.g.ale_lint_on_enter = 1
vim.g.ale_lint_on_save = 1
vim.g.ale_lint_on_insert_leave = 1
vim.g.ale_lint_on_text_changed = 1
vim.g.ale_fix_on_save = 1
-- Custom function for completely toggling ale linting
function _G.toggle_ale_linting()
    if (vim.g.ale_lint_on_insert_leave == 0) then
        vim.api.nvim_command("ALEEnable")
        vim.g.ale_lint_on_enter = 1
        vim.g.ale_lint_on_save = 1
        vim.g.ale_lint_on_insert_leave = 1
        vim.g.ale_lint_on_text_changed = 1
        vim.g.ale_fix_on_save = 1
    else
        vim.api.nvim_command("ALEDisable")
        vim.g.ale_lint_on_enter = 0
        vim.g.ale_lint_on_save = 0
        vim.g.ale_lint_on_insert_leave = 0
        vim.g.ale_lint_on_text_changed = 0
        vim.g.ale_fix_on_save = 0
    end
end
vim.g.ale_linters = {
    sh = { "shellcheck", },
    python = { "flake8" },
    dockerfile = { "hadolint" },
    terraform = { "terraform_ls" },
    markdown = { "vale" },
    nix = { "nix" },
    ansible = { "ansible-lint" },
}
vim.g.ale_fixers = {
    sh = { "shfmt", },
    python = { "isort", "black" },
    terraform = { "terraform" },
    nix = { "nixfmt" },
}

-- osc-yank
vim.api.nvim_set_keymap('n', '<leader>y', '<cmd>OSCYankRegister 0<cr>', { noremap = true })

-- vim-angry-reviewer
vim.g.AngryReviewerEnglish = 'american'

-- ack.vim
vim.cmd([[
  nnoremap <leader>/ :call AckSearch()<CR><c-w><c-p>
  function! AckSearch()
    call inputsave()
    let term = input('Search: ')
    call inputrestore()
    if !empty(term)
        execute "Ack! " . term
    endif
  endfunction
  " Setting better default settings
  let g:ackprg =
      \ "ack -s -H --nocolor --nogroup --column --ignore-dir=.venv/ --ignore-dir=.vimcache/ --ignore-dir=migrations/ --ignore-dir=.mypy_cache/ --ignore-file=is:tags --nojs --nocss --nosass"
]])

-- camelcasemotion
vim.g.camelcasemotion_key = ','

-- vim-oscyank
-- https://github.com/ojroques/vim-oscyank/issues/26#issuecomment-1145673058
-- Fixing issues with tmux
vim.cmd([[
let g:oscyank_term = 'default'
]])


-- vim-bufkill
vim.api.nvim_set_keymap('n', '<leader>bd', '<cmd>BD<cr>', { noremap = true })


-- vim-markdown
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0
