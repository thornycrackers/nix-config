--
-- A little plugin I made to quickly drop notes around in code when I'm exploring or doing refactoring.
-- You can then list all the notes in the quick fix window.
-- All the notes are saved in a global csv file (can't support commas in notes, whomp whomp)
-- All the code is contained in a single file and the neovim config is at the bottom.
-- Everything is still a work in progress, but it works at least
--
-- How to test outside of nix: nvim -c ':luafile /home/thorny/.nixpkgs/src/nvim/lua/qfnotes.lua'
-- wrapping vim api calls for easier mocking in tests
-- Function to get the current buffer, returns type number
function get_current_buffer() return vim.fn.bufnr('%') end

-- Function to get the current line number, return type number
function get_current_line_number() return vim.fn.line('.') end

-- Function to get the current line count, return type number
function get_line_count() return vim.fn.line('$') end

-- Function to get the current line number, return type string
function get_current_buffer_path() return vim.fn.expand('%:p') end

local symbol_group = "myGroup"
local sign_name = "mySign"
local previous_line_count = get_line_count()

-- Hardcoding directory, so ugly
package.path = os.getenv("HOME") .. "/.nixpkgs/src/nvim/lua/?.lua;" ..
                   package.path
-- Import the utils file
local lib = require('qfnotes_lib')
local CodeNote = require('qfnotes_codenote')
local persist = require('qfnotes_persist')

-- Add a symbol to the neovim gutter
function symbols_add_to_gutter(file_path, line_num)
    sign_attrs = {text = "", texthl = "", linehl = "", numhl = ""}
    vim.fn.sign_define(sign_name, sign_attrs)
    opts = {lnum = line_num}
    vim.fn.sign_place(line_num, symbol_group, sign_name, file_path, opts)
end

-- Clear all codenote symbols in buffer
function symbols_clear_in_buffer()
    local current_buf = get_current_buffer()
    vim.fn.sign_unplace(symbol_group, {buffer = current_buf})
end

-- Read the code note data from the db
-- Centralize all access here
-- Creates the file if it doesn't already exist
function get_code_notes()
    local res = {}
    for k, v in pairs(persist.get_table()) do
        local matches = string.gmatch(k, "([^::]+)")
        local filepath = matches()
        local line_number = matches()
        local contents = v
        local code_note = CodeNote:new(filepath, line_number, contents)
        table.insert(res, code_note)
    end
    return res
end

-- Open a note
function open_note()
    local current_filepath = get_current_buffer_path()
    local current_line_number = get_current_line_number()
    if current_filepath ~= '' then
        local found_note = false
        local code_notes = get_code_notes()
        for _, code_note in ipairs(code_notes) do
            if code_note:get_filepath() == current_filepath then
                local line_num = tonumber(code_note:get_line_number())
                if line_num == current_line_number then
                    local success, error_message = pcall(function()
                        local existing_note = ""
                        if code_note:get_contents() ~= "" then
                            existing_note = code_note:get_contents()
                        end
                        user_input = vim.fn.input("Note: ", existing_note)
                        persist.update_table(code_note:get_key(), user_input)
                        found_note = true
                    end)
                    if not success then
                        print("Error:", error_message)
                    end
                end
            end
        end
        -- If no note was found, then create a new one
        if found_note == false then
            user_input = vim.fn.input("Note: ")
            _create_note(current_filepath, current_line_number, user_input)
            draw_existing_note_symbols()
        end
    else
        print("Note not found")
    end
end

-- Create a new note function for internal use
function _create_note(filepath, line_number, contents)
    local code_note = CodeNote:new(filepath, line_number, contents)
    persist.update_table(code_note:get_key(), code_note:get_value())
end

-- Create a new note function for vim mapping
function create_note()
    local filepath = get_current_buffer_path()
    local line_number = get_current_line_number()
    local contents = ""
    _create_note(filepath, line_number, contents)
    draw_existing_note_symbols()
end

-- Delete a note
function delete_note()
    local filepath = get_current_buffer_path()
    local line_number = get_current_line_number()
    local code_note = CodeNote:new(filepath, line_number)
    persist.remove_key(code_note:get_key())
    symbols_clear_in_buffer()
    draw_existing_note_symbols()
end

-- Loop through and add any note symbols to the current buffer
function draw_existing_note_symbols()
    local current_filepath = get_current_buffer_path()
    if current_filepath ~= '' then
        local code_notes = get_code_notes()
        for _, code_note in ipairs(code_notes) do
            if code_note:get_filepath() == current_filepath then
                line_num = code_note:get_line_number()
                symbols_add_to_gutter(current_filepath, line_num)
            end
        end
    end
    -- Also make sure to set the previous line count every time we enter a
    -- buffer and draw symbols. I think this could technically be it's own
    -- thing but I'll keep it here for now until I have a better reason to not
    -- couple it to drawing existing symbols.
    previous_line_count = get_line_count()
end

-- Put all the notes in the location list
function list_notes()
    local quicklist_items = {}
    for _, code_note in ipairs(get_code_notes()) do
        table.insert(quicklist_items, code_note:to_quicklist_item())
    end
    local current_buf = get_current_buffer()
    local replace_items = 'r'
    vim.fn.setqflist(quicklist_items, replace_items)
    vim.cmd('copen')
end

-- Clear all existing notes
function clear_notes()
    local blank_notes = {}
    persist.set_table(blank_notes)
    symbols_clear_in_buffer()
    draw_existing_note_symbols()
end

function tick(current_line_num)
    if current_line_num == nil then return end

    local new_line_count = get_line_count()
    local current_buffer_path = get_current_buffer_path()
    local code_notes = get_code_notes()

    for _, code_note in ipairs(code_notes) do
        local changes = false
        symbol_filepath = code_note:get_filepath()
        symbol_line_num = tonumber(code_note:get_line_number())
        symbol_content = code_note:get_contents()
        key = code_note:get_key()

        local same_file = symbol_filepath == current_buffer_path
        local should_move = lib.symbol_should_move(current_line_num,
                                                   symbol_line_num)
        if same_file and should_move then
            if new_line_count > previous_line_count then
                persist.remove_key(key)
                local new_line = symbol_line_num +
                                     (new_line_count - previous_line_count)
                _create_note(current_buffer_path, new_line, symbol_content)
                changes = true
            elseif new_line_count < previous_line_count then
                persist.remove_key(key)
                local new_line = symbol_line_num -
                                     (previous_line_count - new_line_count)
                _create_note(current_buffer_path, new_line, symbol_content)
                changes = true
            end
        end
    end

    previous_line_count = new_line_count
    if changes == true then
        symbols_clear_in_buffer()
        draw_existing_note_symbols()
    end
end

local function setup_changedtick_listener(bufnr)
    lib.log("Setting up listener for buffer " .. tostring(bufnr))
    vim.api.nvim_buf_attach(0, false, {
        -- I don't use all the variables but I name all here for ease of reference.
        on_lines = function(lines, buf_handle, changed_tick, first_line_changed,
                            last_line_changed, last_line_in_updated_range)
            local current_line_number = get_current_line_number()
            tick(current_line_number)
        end
    })
end

local setup_listener_callback = function(args)
    setup_changedtick_listener(args.buf)
end

-- After creating a new buffer (except during startup, see VimEnter) or renaming an existing buffer.
vim.api.nvim_create_autocmd("BufNew", {callback = setup_listener_callback})
-- The above autocommand will not trigger on enter
vim.api.nvim_create_autocmd("VimEnter", {callback = setup_listener_callback})

-- Old command
-- autocmd TextChanged,TextChangedI * lua if vim.fn.getline(vim.fn.line('.')) == '' and vim.fn.col('.') == 1 then tick(vim.fn.line('.')) end

-- Register
vim.cmd([[
    augroup MyAutoCommands
        autocmd!
        autocmd BufRead * lua draw_existing_note_symbols()
        autocmd VimEnter * lua draw_existing_note_symbols()
    augroup END
]])
vim.api.nvim_set_keymap('n', '<leader>enc', '<cmd>lua open_note()<cr>',
                        {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>enn', '<cmd>lua create_note()<cr>',
                        {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>end', '<cmd>lua delete_note()<cr>',
                        {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>enl', '<cmd>lua list_notes()<cr>',
                        {noremap = true})
-- vim.api.nvim_set_keymap('n', '<leader>enc', '<cmd>lua clear_notes()<cr>',
--                         {noremap = true})
