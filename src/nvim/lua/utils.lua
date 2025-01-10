function markdown_link_wrap()
    -- Get columns for selected text
    local start_col = vim.fn.col('v')
    local end_col = vim.fn.col('.')

    -- Get the current line number
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local current_line_number = cursor_pos[1]

    -- Get the selected text on the current line
    local current_line = vim.api.nvim_get_current_line()
    selected_text = current_line:sub(start_col, end_col)

    -- Replace the text
    vim.api.nvim_buf_set_text(0, current_line_number - 1, start_col - 1,
                              current_line_number - 1, end_col,
                              {'[' .. selected_text .. '][]'})
    -- Set mouse in brackets and enter insert mode
    vim.api.nvim_win_set_cursor(0, {current_line_number, end_col + 3})
    -- Send the '<Esc>' key to exit visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false,
                                                         true), 'n', true)
    vim.api.nvim_command('startinsert')
end

function markdown_link_wrap_inline()
    -- Get columns for selected text
    local start_col = vim.fn.col('v')
    local end_col = vim.fn.col('.')

    -- Get the current line number
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local current_line_number = cursor_pos[1]

    -- Get the selected text on the current line
    local current_line = vim.api.nvim_get_current_line()
    selected_text = current_line:sub(start_col, end_col)

    -- Replace the text
    vim.api.nvim_buf_set_text(0, current_line_number - 1, start_col - 1,
                              current_line_number - 1, end_col,
                              {'[' .. selected_text .. ']()'})
    -- Set mouse in brackets and enter insert mode
    vim.api.nvim_win_set_cursor(0, {current_line_number, end_col + 3})
    -- Send the '<Esc>' key to exit visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false,
                                                         true), 'n', true)
    vim.api.nvim_command('startinsert')
end

-- Quick command for incrementing urls in markdown
function yank_replace_url()
    vim.api.nvim_feedkeys('yyP', "n", true)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-a>", true, true,
                                                         true), "n", true)
    vim.api.nvim_feedkeys('WC', "n", true)
end

vim.api.nvim_set_keymap('v', '<leader>em', '<cmd>lua markdown_link_wrap()<cr>',
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '<leader>en',
                        '<cmd>lua markdown_link_wrap_inline()<cr>',
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>el', '<cmd>lua yank_replace_url()<cr>',
                        {noremap = true, silent = true})

