-- When writing markdown I like to use Reference-style Links and I put them at
-- the bottom of the document. This function takes an array of lines and parses
-- the content to figure out what the current highest reference is.
function find_highest_reference_number(lines)
    local highest_ref = 0
    local first_ref_index = nil
    for i, line in ipairs(lines) do
        local ref = line:match("^%[(%d+)%]:")
        if ref then
            highest_ref = math.max(highest_ref, tonumber(ref))
            if not first_ref_index then first_ref_index = i end
        end
    end
    return highest_ref, first_ref_index
end

-- Get the all the lines for the entire buffer
function get_lines_for_entire_buffer()
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

-- Set the lines for the entire buffer
function update_entire_buffer(lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

-- Get the start and end of a selection. Meant for functions that are expecting
-- the selection to be on the same line, which is what I used most of these
-- functions for.
function get_start_end_of_selection()
    local start_col = vim.fn.col('v')
    local end_col = vim.fn.col('.')
    return start_col, end_col
end

-- Get the current line number
function get_current_line_num()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    return cursor_pos[1]
end

-- Get current line
function get_current_line() return vim.api.nvim_get_current_line() end

-- Get the currently selected text
function get_current_line_text(start_col, end_col)
    local current_line = get_current_line()
    return current_line:sub(start_col, end_col)
end

-- Simulate pressing the escape key
function press_esc_key()
    local term_codes = vim.api
                           .nvim_replace_termcodes('<Esc>', true, false, true)
    vim.api.nvim_feedkeys(term_codes, 'n', true)
end

function markdown_insert_reference_link()
    local url = vim.fn.input("Enter URL: ")
    if url == "" then return end
    -- Find the highest ref and it's position, then update the buffer
    local lines = get_lines_for_entire_buffer()
    local highest_ref, first_ref_index = find_highest_reference_number(lines)
    local new_ref_num = highest_ref + 1
    local new_ref = string.format("[%d]: %s", new_ref_num, url)
    if first_ref_index then
        table.insert(lines, first_ref_index, new_ref)
    else
        table.insert(lines, new_ref)
    end
    update_entire_buffer(lines)
    -- Get the currently selected visual text and replace `text` with
    -- `[text][x]` where x will be the new highest ref number
    local start_col, end_col = get_start_end_of_selection()
    local current_line_number = get_current_line_num()
    selected_text = get_current_line_text(start_col, end_col)
    local new_text = string.format("[%s][%s]", selected_text, new_ref_num)
    -- Replace the text
    local replace_line = current_line_number - 1
    vim.api.nvim_buf_set_text(0, replace_line, start_col - 1, replace_line,
                              end_col, {new_text})
    press_esc_key()
end

function markdown_link_wrap()
    local start_col, end_col = get_start_end_of_selection()
    local current_line_number = get_current_line_num()
    local selected_text = get_current_line_text(start_col, end_col)
    vim.api.nvim_buf_set_text(0, current_line_number - 1, start_col - 1,
                              current_line_number - 1, end_col,
                              {'[' .. selected_text .. '][]'})
    -- Move mouse inside brackets and enter insert mode
    vim.api.nvim_win_set_cursor(0, {current_line_number, end_col + 3})
    press_esc_key()
    vim.api.nvim_command('startinsert')
end

function markdown_link_wrap_inline()
    local start_col, end_col = get_start_end_of_selection()
    local current_line_number = get_current_line_num()
    local selected_text = get_current_line_text(start_col, end_col)
    -- Replace the text
    vim.api.nvim_buf_set_text(0, current_line_number - 1, start_col - 1,
                              current_line_number - 1, end_col,
                              {'[' .. selected_text .. ']()'})
    -- Set mouse in brackets and enter insert mode
    vim.api.nvim_win_set_cursor(0, {current_line_number, end_col + 3})
    press_esc_key()
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
vim.api.nvim_set_keymap('v', '<leader>es',
                        '<cmd>lua markdown_insert_reference_link()<cr>',
                        {noremap = true, silent = true})

