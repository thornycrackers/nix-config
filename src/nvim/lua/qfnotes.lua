-- Lua qfnotes module
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

local notesdb = os.getenv("HOME") .. "/.notesdb.csv"
local symbol_group = "myGroup"
local sign_name = "mySign"
local previous_line_count = get_line_count()
local csv_headers = "filename,line_number,content"

-- Hardcoding directory, so ugly
package.path = os.getenv("HOME") .. "/.nixpkgs/src/nvim/lua/?.lua;" ..
                   package.path
-- Import the utils file
local lib = require('qfnotes_lib')
lib.log("previous line count " .. previous_line_count)

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
function get_code_note_data() return
    lib.csv_read_or_create(notesdb, csv_headers) end

-- Open a note
function open_note()
    local current_buffer_path = get_current_buffer_path()
    local current_line_number = get_current_line_number()
    if current_buffer_path ~= '' then
        local found_note = false
        local code_note_table = get_code_note_data()
        for _, row in ipairs(code_note_table) do
            if row["filename"] == current_buffer_path then
                if tonumber(row["line_number"]) == current_line_number then
                    local success, error_message = pcall(function()
                        local existing_note = ""
                        if row["content"] ~= nil then
                            existing_note = row["content"]
                        end
                        user_input = vim.fn.input("Note: ", existing_note)
                        lib.csv_update_line_by_columns_from_csv(notesdb,
                                                                row["filename"],
                                                                row["line_number"],
                                                                user_input)
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
            create_note()
            user_input = vim.fn.input("Note: ")
            lib.csv_update_line_by_columns_from_csv(notesdb,
                                                    current_buffer_path,
                                                    current_line_number,
                                                    user_input)
        end
    else
        print("Note not found")
    end
end

-- Create a new note
function create_note()
    local current_buffer_path = get_current_buffer_path()
    local current_line_number = get_current_line_number()
    local data = {{current_buffer_path, current_line_number, ""}}
    lib.csv_append(notesdb, data)
    draw_existing_note_symbols()
end

-- Delete a note
function delete_note()
    local current_buffer_path = get_current_buffer_path()
    local current_line_number = tostring(get_current_line_number())
    lib.csv_remove_line_by_columns_from_csv(notesdb, current_buffer_path,
                                            current_line_number)
    symbols_clear_in_buffer()
    draw_existing_note_symbols()
end

-- Loop through and add any note symbols to the current buffer
function draw_existing_note_symbols()
    local current_buffer_path = get_current_buffer_path()
    if current_buffer_path ~= '' then
        local code_note_table = get_code_note_data()
        for _, row in ipairs(code_note_table) do
            if row["filename"] == current_buffer_path then
                line_number = row["line_number"]
                symbols_add_to_gutter(current_buffer_path, line_number)
            end
        end
    else
        print("Current buffer does not have a valid path")
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
    for _, row in ipairs(get_code_note_data()) do
        local quicklist_item = {
            filename = row["filename"],
            lnum = row["line_number"],
            col = 0,
            text = row["content"]
        }
        table.insert(quicklist_items, quicklist_item)
    end
    local current_buf = get_current_buffer()
    local replace_items = 'r'
    -- Set the quickfix list
    vim.fn.setqflist(quicklist_items, replace_items)
    vim.cmd('copen')
end

-- Clear all existing notes
function clear_notes()
    local file = io.open(notesdb, "w") -- Open the file in write mode
    file:write(csv_headers .. "\n")
    file:close()
    symbols_clear_in_buffer()
    draw_existing_note_symbols()
end

function gogogo(current_line_num)
    if current_line_num == nil then return end
    lib.log("gogogo current line number: " .. current_line_num)
    lib.log("previous line count" .. previous_line_count)

    local new_line_count = get_line_count()
    lib.log("gogogo new_line_count: " .. new_line_count)
    local current_buffer_path = get_current_buffer_path()
    local code_note_table = get_code_note_data()

    for _, row in ipairs(code_note_table) do
        symbol_line_num = row["line_number"]
        symbol_content = row["content"]
        if lib.symbol_should_move(current_line_num, tonumber(symbol_line_num)) then
            if new_line_count > previous_line_count then
                lib.csv_remove_line_by_columns_from_csv(notesdb,
                                                        current_buffer_path,
                                                        symbol_line_num)
                local new_line = tonumber(symbol_line_num) +
                                     (new_line_count - previous_line_count)
                local data = {{current_buffer_path, new_line, symbol_content}}
                lib.csv_append(notesdb, data)
            elseif new_line_count < previous_line_count then
                lib.csv_remove_line_by_columns_from_csv(notesdb,
                                                        current_buffer_path,
                                                        symbol_line_num)
                local new_line = tonumber(symbol_line_num) -
                                     (previous_line_count - new_line_count)
                local data = {{current_buffer_path, new_line, symbol_content}}
                lib.csv_append(notesdb, data)
            end
        end
        previous_line_count = new_line_count
        symbols_clear_in_buffer()
        draw_existing_note_symbols()
    end
end

-- Register
vim.cmd([[
    augroup MyAutoCommands
        autocmd!
        autocmd BufRead * lua draw_existing_note_symbols()
        autocmd VimEnter * lua draw_existing_note_symbols()
        autocmd TextChanged,TextChangedI <buffer> lua if vim.fn.getline(vim.fn.line('.')) == '' and vim.fn.col('.') == 1 then gogogo(vim.fn.line('.')) end
    augroup END
]])
vim.api.nvim_set_keymap('n', '<leader>eno', '<cmd>lua open_note()<cr>',
                        {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>enn', '<cmd>lua create_note()<cr>',
                        {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>end', '<cmd>lua delete_note()<cr>',
                        {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>enl', '<cmd>lua list_notes()<cr>',
                        {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>enc', '<cmd>lua clear_notes()<cr>',
                        {noremap = true})
