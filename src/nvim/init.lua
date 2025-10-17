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
vim.cmd(
    [[autocmd BufWritePre,FileWritePre,FileAppendPre,FilterWritePre * :lua preserve('%s/\\s\\+$//ge')]])

-- Debug function for printing lua tables
function _G.print_table(mytable)
    for k, v in pairs(mytable) do
        if (type(v) == "table") then
            print(k)
            print_table(v)
        else
            print(k, v)
        end
    end
end

-- Shorcut for the function to save space
kmap = vim.api.nvim_set_keymap

-- Set up spacebar as leader
-- https://icyphox.sh/blog/nvim-lua/
kmap('n', '<Space>', '', {})
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
autocmd Filetype markdown setlocal ts=2 sw=2 sts=0 expandtab
autocmd BufNewFile,BufRead *.nomad setfiletype hcl
autocmd BufNewFile,BufRead *.yaml setfiletype yaml.ansible
autocmd BufNewFile,BufRead *.yml setfiletype yaml.ansible
autocmd BufNewFile,BufRead *.tfvars setfiletype terraform
autocmd FileType nix setlocal commentstring=#\ %s
autocmd FileType terraform setlocal commentstring=#\ %s
]]
-- https://github.com/neovim/nvim-lspconfig/issues/2685#issuecomment-1623575758
-- ^ for the tfvars to terraform above
vim.o.relativenumber = true
-- Distable word wrap
vim.o.wrap = false
vim.o.history = 1000
-- Wildmode show list, complete to first result
vim.o.wildignore =
    "*/app/cache,*/vendor,*/env,*.pyc,*/venv,*/__pycache__,*/venv"
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
vim.o.foldlevel = 99

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

-- Preserve the location in the location list after saving
local function preserve_loclist_position()
    local loclist = vim.fn.getloclist(0, {idx = 0})
    vim.b.loclist_idx = loclist.idx
end
local function restore_loclist_position()
    local idx = vim.b.loclist_idx
    if idx then
        vim.defer_fn(function()
            vim.fn.setloclist(0, {}, 'r', {idx = idx})
        end, 100)
    end
end
vim.api.nvim_create_autocmd("User", {
    pattern = "LintFinished",
    callback = function()
        preserve_loclist_position()
        vim.defer_fn(restore_loclist_position, 200)
    end
})

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

-- Custom function to number visually selected lines
function NumberSelectedLines()
    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]
    for i = start_line, end_line do
        local line_content = vim.fn.getline(i)
        local new_content = string.format("%d. %s", i - start_line + 1,
                                          line_content)
        vim.fn.setline(i, new_content)
    end
end
vim.api.nvim_create_user_command("Number", NumberSelectedLines, {range = true})

-- Function to take the current paragraph and split it into separate lines
-- It also handles the use case of the paragraph being the very last line in
-- the file. A use case that my old function using vip would not handle. A very
-- annoying edgecase to hit while in mid flow.
local function split_paragraph()
    -- I don't know if this is the most efficient way of doing things, but I
    -- think it makes things easier to put everything on one line and then
    -- process the single line. Most paragraphs I'm working with are not that
    -- big so I can't see this being too much of a big deal.
    vim.cmd('normal! vipJ')
    local line = vim.api.nvim_get_current_line()
    local sentences = {}
    for sentence in string.gmatch(line, '[^%.!?]+[%.!?]*') do
        table.insert(sentences, vim.trim(sentence))
    end
    local current_line = vim.fn.line('.')
    vim.api.nvim_buf_set_lines(0, current_line - 1, current_line, false,
                               sentences)
end

-- Keymaps
noremap = {noremap = true}
-- noh gets rid of highlighted search results
kmap('n', '<leader><leader>', ':noh<cr>', noremap)
-- `jj` maps to escape
kmap('i', 'jj', '<esc>', noremap)
-- Visually select last copied text
kmap('n', 'gp', "`[v`]", noremap)
-- Changelist navigation
kmap('n', '<leader>co', '<cmd>copen<cr>', noremap)
kmap('n', '<leader>cc', '<cmd>cclose<cr>', noremap)
kmap('n', '<leader>cp', "<cmd>cprev<cr>", noremap)
kmap('n', '<leader>cn', "<cmd>cnext<cr>", noremap)
kmap('n', '<leader>lp', "<cmd>lprev<cr>", noremap)
kmap('n', '<leader>ln', "<cmd>lnext<cr>", noremap)
kmap('n', '<leader>lo', "<cmd>lopen<cr>", noremap)
kmap('n', '<leader>lc', "<cmd>lclose<cr>", noremap)
kmap('n', '<leader>ll', "<Plug>(Luadev-Run)", noremap)
-- Shorcut to insert pudb statements for python
kmap('n', '<leader>epu', 'ofrom pudb import set_trace; set_trace()<esc>',
     noremap)
-- Shorcut to embed ipython
kmap('n', '<leader>epi',
     'ofrom IPython import embed<cr>from traitlets.config import get_config<cr>c = get_config()<cr>c.InteractiveShellEmbed.colors = "Linux"<cr>embed(config=c)<esc>',
     noremap)
-- yank current word and make print statement on next line
kmap('n', '<leader>epp', 'yiwoprint("<esc>pa: ", <esc>pa)<esc>V=', noremap)
-- Easy new tab creation
kmap('n', '<c-w>t', "<cmd>tabnew<cr>", noremap)
kmap('n', '<c-w><c-f>', '<c-w>f<c-w>T', noremap)
kmap('n', '<c-w><c-]>', '<c-w>v<c-]><c-w>T', noremap)
kmap('n', '<c-w><c-t>', '<c-w>v<c-w>T', noremap)
kmap('n', '<c-w><c-w>', '<cmd>w<cr>', noremap)
kmap('n', '<c-w><c-a>', '<cmd>wa<cr>', noremap)
kmap('n', '<c-q><c-a>', '<cmd>qa!<cr>', noremap)
kmap('n', '<leader>ee', '<cmd>e!<cr>', noremap)
kmap('n', '<expr> k', [[(v:count > 1 ? "m'" . v:count : '') . 'k']], noremap)
kmap('n', '<expr> j', [[(v:count > 1 ? "m'" . v:count : '') . 'j']], noremap)
-- Call Ale Fix
kmap('n', '<leader>ef', '<cmd>ALEFix<cr>', noremap)
kmap('n', '<leader>el', '<cmd>ALELint<cr>', noremap)
kmap('n', '<leader>et', '<cmd>lua toggle_ale_linting()<cr>', noremap)
kmap('n', '<leader>ei', '<cmd>lua toggle_vale_info_statements()<cr>', noremap)
-- Markdown functions
kmap('n', '<leader>po',
     '<cmd>AngryReviewer<cr><c-w>k<cmd>ALELint<cr><cmd>lopen<cr><c-w>k', noremap)
kmap('n', '<leader>pse', '<cmd>LanguageToolSetUp<cr>', noremap)
kmap('n', '<leader>psc', '<cmd>LanguageToolCheck<cr>', noremap)
kmap('n', '<leader>psu', '<cmd>LanguageToolSummary<cr>', noremap)
kmap('n', '<leader>psl', '<cmd>LanguageToolClear<cr>', noremap)
kmap('n', '<leader>pc', '<cmd>cclose<cr><cmd>lclose<cr>', noremap)
kmap('n', '<leader>pg', '<cmd>Goyo<cr>', noremap)
kmap('n', '<leader>pp', 'vipJVgq', noremap)
vim.keymap.set('n', '<leader>pl', split_paragraph, noremap)

-- Add "il" text object to mean "in line"
kmap('x', 'il', 'g_o^', noremap)
kmap('o', 'il', '<cmd>normal vil<cr>', noremap)
kmap('n', '<leader>v', '^vg_o^', noremap)
-- Shortcuts to help take notes
-- Print current filepath with line number to reference
kmap('n', '<leader>,p', '<cmd>put =expand(\'%:p\') . \':\' . line(\'.\')<cr>',
     noremap);
kmap('n', '<leader>,i',
     '<Cmd>edit ' .. vim.fn.expand('~') .. '/Obsidian/MyVault/index.md<CR>',
     noremap);
kmap('n', '<leader>,n',
     '<Cmd>edit ' .. vim.fn.expand('~') .. '/Obsidian/MyVault/notes.md<CR>',
     noremap);
-- Search and replace word under cursor
kmap('n', '<Leader>r', ':%s/<c-r><c-w>/', {noremap = true, silent = true})
-- In insert mode, insert a timestamp with the current time
kmap('i', '<F5>', '<c-r>=strftime("%x %H:%M:%S")<cr>', noremap)

-- Build a custom status line
local status_line = {
    '%#PrimaryBlock#', '%#SecondaryBlock#', '%#Blanks#', '%f', '%m', '%=',
    '%#SecondaryBlock#', '%l,%c ', '%#PrimaryBlock#', '%{&filetype}'
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
    highlight = {enable = true},
    indent = {enable = true},
    rainbow = {
        enable = true
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
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end
    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
    -- Mappings.
    local opts = {noremap = true, silent = true}
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>',
                   opts)
    buf_set_keymap('n', '<spnce>wa',
                   '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr',
                   '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl',
                   '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
                   opts)
    buf_set_keymap('n', '<space>D',
                   '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
                   opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>e',
                   '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
                   opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',
                   opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>',
                   opts)
    buf_set_keymap('n', '<space>q',
                   '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>',
                   opts)
end
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- local servers = { 'pyls', 'rust_analyzer', 'tsserver' }
local servers = {
    'jedi_language_server', 'bashls', 'terraformls', 'ansiblels', 'nil_ls'
}
-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
-- Setup language servers
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        flags = {debounce_text_changes = 150},
        capabilities = capabilities
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
            select = true
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
        end
    },
    sources = {{name = 'nvim_lsp'}}
}

-- nvim-fzf
kmap('n', '<leader>fb', "<cmd>let g:fzf_buffers_jump = 0<cr><cmd>Buffers<cr>",
     {noremap = true})
kmap('n', '<leader>ft', "<cmd>Tags<cr>", {noremap = true})
kmap('n', '<leader>fm', "<cmd>Marks<cr>", {noremap = true})
kmap('n', '<leader>fg', "<cmd>GF?<cr>", {noremap = true})
vim.cmd(
    [[let $FZF_DEFAULT_COMMAND = 'find . -type f -not -path "*/\.git/*" -not -path "*/\.mypy_cache/*" -not -path "*/\.venv/*" -not -path "*/\node_modules/*" ']])
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
kmap('n', '<leader>ew', '<cmd>ArgWrap<cr>', {noremap = true})

-- vim-fugitive
kmap('n', '<leader>du', '<cmd>diffupdate<cr>', {noremap = true})
kmap('n', '<leader>dd', '<cmd>diffget<cr>', {noremap = true})
kmap('n', '<leader>df', '<cmd>diffput<cr>', {noremap = true})
kmap('n', '<leader>dn', ']c', {noremap = true})
kmap('n', '<leader>dp', '[c', {noremap = true})
kmap('n', '<leader>gs', '<cmd>Git<cr>', {noremap = true})
kmap('n', '<leader>gc', '<cmd>Git commit<cr>', {noremap = true})
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
kmap('n', '<leader>gb', '<cmd>Git blame<cr>', {noremap = true})
kmap('n', '<leader>gd', '<cmd>Gdiffsplit<cr>', {noremap = true})

-- indent-blankline-nvim
require("ibl").setup()

-- lf-vim
-- vim-floaterm
vim.g.floaterm_opener = "edit"
vim.g.floaterm_width = 0.99
vim.g.floaterm_height = 0.99
kmap('n', '<leader>m', '<cmd>Lf<cr>', {noremap = true});
kmap('n', '<leader>n', '<cmd>LfWorkingDirectory<cr>', {noremap = true});

-- hop-nvim
kmap('', '<leader>ss', '<cmd>HopChar2<cr>', {noremap = true})
-- set the pattern as a variable to avoid escaping issues
vim.cmd([[
let g:hop_file_pattern = '\v(\.\/|\.\.\/|\w+\/)+\w+(\.\w+)?'
nnoremap <Leader>sf :lua HopToFilePath()<cr>
]])
function HopToFilePath()
    -- Use hop to look for file paths and visually select, Then run "gF" to go
    -- to file. I use "gF" because vim-fetch understands line numbers
    require'hop'.hint_patterns({}, vim.g.hop_file_pattern)
    vim.schedule(function() vim.api.nvim_feedkeys('gF', 'n', true) end)
end
require'hop'.setup {keys = 'etovxqpdygfblzhckisuran'}

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
-- I actually don't want neovim to look for tools inside of .venvs because that
-- tooling doesn't work on nix. Instead I hardcode the references to tools I
-- want.
vim.g.ale_virtualenv_dir_names = {'neverfindingthis'}
vim.g.ale_linters = {
    sh = {"shellcheck"},
    python = {"flake8"},
    dockerfile = {"hadolint"},
    terraform = {"terraform_ls"},
    markdown = {"vale"},
    nix = {"nix"},
    ansible = {"ansible-lint"}
}
vim.g.ale_python_flake8_options = "--max-line-length=88"
vim.g.ale_fixers = {
    sh = {"shfmt"},
    python = {"isort", "ruff_format"},
    terraform = {"terraform"},
    nix = {"nixfmt"},
    lua = {"lua-format"}
}
-- Function for temporarily toggling vale's alert level while writing.
-- Mostly used for because write-good's E-Prime alert can get very noisy while
-- editing, but is still good to consider.
local show_info = true
function toggle_vale_info_statements()
    show_info = not show_info
    if show_info then
        vim.g.ale_markdown_vale_options = "--minAlertLevel=suggestion"
    else
        vim.g.ale_markdown_vale_options = "--minAlertLevel=warning"
    end
    vim.cmd("ALELint")
end

-- Use 4 spaces for shfmt, not tabs. Indent case statements
vim.g.ale_sh_shfmt_options = '-i 4 -ci'

-- osc-yank
kmap('n', '<leader>y', '<cmd>OSCYankRegister 0<cr>', {noremap = true})

-- vim-angry-reviewer
vim.g.AngryReviewerEnglish = 'american'

-- ack.vim
vim.api.nvim_create_user_command("AckFzf", function(opts)
    local fzf = require("fzf-lua")
    fzf.grep({search = opts.args, cmd = "ack --nogroup --nocolor --smart-case"})
end, {nargs = 1})
kmap('n', '<leader>/', ':AckFzf ', {noremap = true, silent = false})

-- vim-oscyank
-- https://github.com/ojroques/vim-oscyank/issues/26#issuecomment-1145673058
-- Fixing issues with tmux
vim.cmd([[
let g:oscyank_term = 'default'
]])

-- vim-bufkill
kmap('n', '<leader>bd', '<cmd>BD<cr>', {noremap = true})

-- vim-markdown
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0

-- mini.nvim
-- Mini align provides nice interactive alignments, similar to terraform fmt.
require("mini.align").setup()
-- Hints for bindings
local miniclue = require('mini.clue')
require('mini.clue').setup({
    triggers = {{mode = 'n', keys = '<leader>'}},
    clues = {
        {mode = 'n', keys = '<leader>ep', desc = 'Extra python things'},
        {mode = 'n', keys = '<leader>p', desc = 'Writing things'}
    },
    debug = true -- Enables debug messages
})

-- Typically, I think you're supposed to define these as clues, but they
-- weren't working for me. I could only get this level to print correctly in
-- the box with this function
local set_desc = miniclue.set_mapping_desc
set_desc('n', '<leader>epp', 'Yank word, create print statement')
set_desc('n', '<leader>epu', 'pudb set trace')
set_desc('n', '<leader>epi', 'embed ipython')
set_desc('n', '<leader>pl', 'Split paragraph into lines')
set_desc('n', '<leader>pp', 'Word-wrap paragraph')

require("codecompanion").setup({
    strategies = {
        chat = {adapter = "githubmodels"},
        inline = {adapter = "githubmodels"}
    }
})
