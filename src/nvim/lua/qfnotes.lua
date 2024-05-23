-- Lua qfnotes module
--
-- A little plugin I made to quickly drop notes around in code when I'm exploring or doing refactoring.
-- You can then list all the notes in the quick fix window.
-- All the notes are saved in a global csv file (can't support commas in notes, whomp whomp)
-- All the code is contained in a single file and the neovim config is at the bottom.
-- Everything is still a work in progress, but it works at least
--
-- How to test outside of nix: nvim -c ':luafile /home/thorny/.nixpkgs/src/nvim/lua/qfnotes.lua'
--
-- Ideas:
--   - Namespacing notes?

local notesdb = os.getenv("HOME") .. "/.notesdb.csv"
local symbol_group = "myGroup"
local symbol_name = "mySign"
local previous_line_count = vim.fn.line('$')


-- Hardcoding directory, so ugly
package.path = os.getenv("HOME") .. "/.nixpkgs/src/nvim/lua/?.lua;" .. package.path
-- Import the utils file
local qfnotes_utils = require('qfnotes_utils')


-- Generic function for printing a table for debugging purposes
function printTable(table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            print(key .. ": {")
            printTable(value)
            print("}")
        else
            print(key .. ": " .. tostring(value))
        end
    end
end

-- Add a symbol to the neovim gutter
function symbols_add_to_gutter(file_path, line_num)
    vim.fn.sign_define(symbol_name, { text = "", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_place(line_num, symbol_group, symbol_name, file_path, {lnum= line_num})
end

-- Clear all codenote symbols in buffer
function symbols_clear_in_buffer()
    local current_buf = vim.fn.bufnr('%')
    vim.fn.sign_unplace(symbol_group, {buffer=current_buf})
end

-- Function to write a table of data to a CSV file
function csv_write(filename, data)
    local file = io.open(filename, "w") -- Open the file in write mode
    if file then
        -- Write header
        file:write(table.concat(data[1], ",") .. "\n")
        -- Write data
        for i = 2, #data do
            file:write(table.concat(data[i], ",") .. "\n")
        end
        file:close()
    else
        error("Error: Unable to open file for writing.")
    end
end

-- Function to append a table of data to a CSV file
function csv_append(filename, data)
    local file = io.open(filename, "a") -- Open the file in append mode
    if file then
        -- Append data
        for _, row in ipairs(data) do
            file:write(table.concat(row, ",") .. "\n")
        end
        file:close() -- Close the file
        print("Data appended to CSV file '" .. filename .. "' successfully.")
    else
        print("Error: Unable to open file for appending.")
    end
end

-- Function to remove a line based on matching values in two columns from a CSV file
-- TODO: Make the a better function. It's hardcoded to 1 and 2 columns right now
function csv_remove_line_by_columns_from_csv(filename, column1Value, column2Value)
    local file = io.open(filename, "r") -- Open the file in read mode
    if file then
        local lines = {}  -- Table to store lines of the file
        -- Read each line and store it in the 'lines' table
        for line in file:lines() do
            table.insert(lines, line)
        end
        file:close()  -- Close the file
        -- Open the file in write mode to overwrite its content
        file = io.open(filename, "w")
        if file then
            -- Write all lines except the one where both column values match
            for _, currentLine in ipairs(lines) do
                local columns = {}
                for columnValue in currentLine:gmatch("[^,]+") do
                    table.insert(columns, columnValue)
                end
                if tostring(columns[1]) ~= tostring(column1Value) or tostring(columns[2]) ~= tostring(column2Value) then
                    file:write(currentLine .. "\n")
                end
            end
            file:close()  -- Close the file
        else
            print("Error: Unable to open file for writing.")
        end
    else
        print("Error: Unable to open file for reading.")
    end
end


function csv_update_line_by_columns_from_csv(filename, column1Value, column2Value, column3Value)
    local file = io.open(filename, "r") -- Open the file in read mode
    if file then
        local lines = {}  -- Table to store lines of the file
        -- Read each line and store it in the 'lines' table
        for line in file:lines() do
            table.insert(lines, line)
        end
        file:close()  -- Close the file
        -- Open the file in write mode to overwrite its content
        file = io.open(filename, "w")
        if file then
            -- Write all lines except the one where both column values match
            for _, currentLine in ipairs(lines) do
                local columns = {}
                for columnValue in currentLine:gmatch("[^,]+") do
                    table.insert(columns, columnValue)
                end
                if tostring(columns[1]) ~= tostring(column1Value) or tostring(columns[2]) ~= tostring(column2Value) then
                    file:write(currentLine .. "\n")
                else
                    if column3Value == nil then
                        file:write(column1Value .. "," .. column2Value .. "," .. "\n")
                    else
                        file:write(column1Value .. "," .. column2Value .. "," .. column3Value .. "\n")
                    end
                end
            end
            file:close()  -- Close the file
        else
            print("Error: Unable to open file for writing.")
        end
    else
        print("Error: Unable to open file for reading.")
    end
end

-- Reade the code note data from the db
-- Centralize all access here
function get_code_note_data()
    return qfnotes_utils.csv_read(notesdb)
end

-- Open a note
function open_note()
    -- Get the full path of the current buffer
    local current_buffer_path = vim.fn.expand('%:p')
    -- Get the current line number
    local current_line_number = vim.fn.line('.')
    -- Check if the buffer has a valid path
    if current_buffer_path ~= '' then
        -- Loop through the csv data and see if our buffer and line number match
        local found_note = false
        local code_note_table = get_code_note_data()
        if not code_note_table then
            clear_notes()
            code_note_table = get_code_note_data()
        end
        for _, row in ipairs() do
            if row["filename"] == current_buffer_path then
                if tonumber(row["line_number"]) == current_line_number then
                    print("Trying to open the floating window")
                    local success, error_message = pcall(function()
                        -- open_floating_buffer(do_something)
                        local user_input = ""
                        if row["content"] == nil then
                            user_input = vim.fn.input("Note: ")
                        else
                            user_input = vim.fn.input("Note: ", row["content"])
                        end
                        csv_update_line_by_columns_from_csv(notesdb, row["filename"], row["line_number"], user_input)
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
            csv_update_line_by_columns_from_csv(notesdb, current_buffer_path, current_line_number, user_input)
        end
    else
        print("Note not found")
    end
end

-- Calculate the center position, used when opening a new window
local function calculate_center_pos(width, height)
    local win_width = vim.api.nvim_get_option("columns")
    local win_height = vim.api.nvim_get_option("lines")
    local row = math.floor((win_height - height) / 2)
    local col = math.floor((win_width - width) / 2)
    return { row = row, col = col }
end

-- Open a new buffer in a floating window and center it
function open_floating_buffer(file_path)
    -- Create a new empty buffer
    local bufnr = vim.api.nvim_create_buf(true, false)
    -- Set the buffer options as needed
    vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
    -- Define the dimensions of the floating window
    local float_width = math.floor(vim.api.nvim_get_option("columns") * 0.7)
    local float_height = math.floor(vim.api.nvim_get_option("lines") * 0.7)
    -- Calculate the center position for the floating window
    local center_pos = calculate_center_pos(float_width, float_height)
    -- Open a new floating window with the created buffer
    local win_config = {
        relative = 'editor',
        width = float_width,
        height = float_height,
        row = center_pos.row,
        col = center_pos.col,
        style = 'minimal',
        border = 'single',
    }
    local win_id = vim.api.nvim_open_win(bufnr, true, win_config)
    -- Set the 'winhighlight' option to match the colorscheme
    vim.api.nvim_win_set_option(win_id, 'winhighlight', 'Normal:NormalNC,NormalNC:Normal,NormalNC:NormalNC')
    -- If a file path is provided, load the file into the buffer
    if file_path then
        vim.api.nvim_command('silent edit ' .. vim.fn.fnameescape(file_path))
    end
    return bufnr, win_id
end

function create_note()
    local current_buffer_path = vim.fn.expand('%:p')
    local current_line_number = vim.fn.line('.')
    local data = {
        {current_buffer_path, current_line_number, ""}
    }
    csv_append(notesdb, data)
    draw_existing_note_symbols()
end

function delete_note()
    local current_buffer_path = vim.fn.expand('%:p')
    local current_line_number = tostring(vim.fn.line('.'))
    csv_remove_line_by_columns_from_csv(notesdb, current_buffer_path, current_line_number)
    symbols_clear_in_buffer()
    draw_existing_note_symbols()
end

-- Loop through and add any note symbols to the current buffer
function draw_existing_note_symbols()
    -- Get the full path of the current buffer
    local current_buffer_path = vim.fn.expand('%:p')
    -- Check if the buffer has a valid path
    if current_buffer_path ~= '' then
        -- Loop through the csv data and see if our buffer matches
        local code_note_table = get_code_note_data()
        if not code_note_table then
            clear_notes()
            code_note_table = get_code_note_data()
        end
        for _, row in ipairs(code_note_table) do
            if row["filename"] == current_buffer_path then
                -- create the symbol on the line
                line_number = row["line_number"]
                symbols_add_to_gutter(current_buffer_path, line_number)
            end
        end
    else
        print("Current buffer does not have a valid path")
    end
end

-- Put all the notes in the location list
function list_notes()
    local items = {}
    for _, row in ipairs(get_code_note_data()) do
        table.insert(items, {
            filename=row["filename"],
            lnum=row["line_number"],
            col=0,
            text=row["content"],
        })
    end
    local current_buf = vim.fn.bufnr('%')
    local replace_items = 'r'
    -- Set the quickfix list
    vim.fn.setqflist(items, replace_items)
    vim.cmd('copen')
end

-- Clear all existing notes
function clear_notes()
    local file = io.open(notesdb, "w") -- Open the file in write mode
    file:write("filename,line_number,content\n")
    file:close()
    symbols_clear_in_buffer()
    draw_existing_note_symbols()
end

function gogogo(line_number)
    if line_number == nil then
        return
    end

    local new_line_count = vim.fn.line('$')
    local current_buffer_path = vim.fn.expand('%:p')
    local code_note_table = get_code_note_data()
    if not code_note_table then
        clear_notes()
        code_note_table = get_code_note_data()
    end
    for _, row in ipairs(code_note_table) do
        if line_number <= tonumber(row["line_number"]) then
            print(row["line_number"])
            print("change")
            csv_remove_line_by_columns_from_csv(notesdb, current_buffer_path, row["line_number"], "")
            if new_line_count > previous_line_count then
                local data = {
                    {current_buffer_path, tonumber(row["line_number"]) + (new_line_count - previous_line_count), ""}
                }
                print("A line was added.")
                csv_append(notesdb, data)
            elseif new_line_count < previous_line_count then
                local data = {
                    {current_buffer_path, tonumber(row["line_number"]) - (previous_line_count - new_line_count), ""}
                }
                print("A line was removed.")
                csv_append(notesdb, data)
            else
                print("No change in line count.")
            end
            previous_line_count = new_line_count
            symbols_clear_in_buffer()
            draw_existing_note_symbols()
        else
            print(row["line_number"])
            print("no change")
        end
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
vim.api.nvim_set_keymap('n', '<leader>eno', '<cmd>lua open_note()<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>enn', '<cmd>lua create_note()<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>end', '<cmd>lua delete_note()<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>enl', '<cmd>lua list_notes()<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>enc', '<cmd>lua clear_notes()<cr>', { noremap = true })
