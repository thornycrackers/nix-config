-- All kinds of little utils that I split up for unit testing
-- Map function
function map(tbl, f)
    local t = {}
    for k, v in pairs(tbl) do t[k] = f(v) end
    return t
end

-- Iterator to table
function iter_to_table(iter)
    local t = {}
    for v in iter do table.insert(t, v) end
    return t
end

-- Simple function for reading a file
function read_file(file_path)
    local success, file = pcall(io.open, file_path, "r")
    local lines = {}
    if success and file then
        for line in file:lines() do table.insert(lines, line) end
        file:close()
    else
        error("Error opening or reading the file")
    end
    return lines
end

-- Split a string be a delimiter
function split_string(input_string, delimiter)
    local parts = {}
    for part in input_string:gmatch("[^" .. delimiter .. "]+") do
        table.insert(parts, part)
    end
    return parts
end

-- Generic function for printing a table for debugging purposes
function pprint(table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            print(key .. ": {")
            pprint(value)
            print("}")
        else
            print(key .. ": " .. tostring(value))
        end
    end
end

-- Dumb function for printing file contents, used for easy debugging
function fprint(filename)
    local file = io.open(filename, "r")
    local content = file:read("*all")
    print(content)
    file:close()
end

-- Check whether a file exists or not
function file_exists(file_path)
    local file = io.open(file_path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

-- Create a table from two arrays
function arrays_to_table(array1, array2)
    local length = math.min(#array1, #array2)
    local result = {}
    for i = 1, length do result[array1[i]] = array2[i] end
    return result
end

-- Read a csv file
function csv_read(filename)
    local lines = read_file(filename)
    local headers = split_string(lines[1], ",")
    local res = {}
    for i = 2, #lines do
        values = split_string(lines[i], ",")
        table.insert(res, arrays_to_table(headers, values))
    end
    return res
end

-- Read a csv, create if doesn't exist
function csv_read_or_create(filename, headers)
    if not file_exists(filename) then
        local file = io.open(filename, "w")
        file:write(headers .. "\n")
        file:close()
        return {}
    end
    return csv_read(filename)
end

-- Write a csv file
function csv_write(filename, data)
    local file = io.open(filename, "w")
    if file then
        for _, item in ipairs(data) do
            local res = min_concat_two(item)
            res = res .. "\n"
            file:write(res)
        end
        file:close()
    else
        error("Error: Unable to open file for writing.")
    end
end

-- Append a csv file
function csv_append(filename, data)
    local file = io.open(filename, "a")
    if file then
        for _, row in ipairs(data) do
            local res = min_concat_two(row)
            res = res .. "\n"
            file:write(res)
        end
        file:close()
    else
        error("Error: Unable to open file " .. filename .. " for appending.")
    end
end

-- Filter an array via a function
function filter(array, predicate)
    local res = {}
    for _, v in ipairs(array) do
        if predicate(v) then table.insert(res, v) end
    end
    return res
end

-- Function to remove a line based on matching values in two columns from a CSV file
-- TODO: This is being refactored via the old method signature. Clean up later cause ugly
function csv_remove_line_by_columns_from_csv(filename, column1Value,
                                             column2Value)
    -- This function will keep the lines that don't match the one we're looking for
    -- It's janky because it deletes from a csv file based on the first two
    -- column values which are a unique ID in our case consisting of "filepath" and "line number"
    local function keep_line(line)
        prefix = column1Value .. "," .. column2Value .. ","
        return line:sub(1, #prefix) ~= prefix
    end
    local lines = read_file(filename)
    local new_lines = filter(lines, keep_line)
    new_data = map(new_lines, function(line) return split_string(line, ",") end)
    csv_write(filename, new_data)
end

-- Function to update a csv file based on the first two column values
-- TODO: This is being refactored via the old method signature. Clean up later cause ugly
function csv_update_line_by_columns_from_csv(filename, column1Value,
                                             column2Value, newValue)
    -- This function looks for the specific line and updates it if found
    local function update_line(line)
        prefix = column1Value .. "," .. column2Value
        if line:sub(1, #prefix) == prefix then
            return prefix .. "," .. newValue
        else
            return line
        end
    end
    local lines = read_file(filename)
    local new_lines = map(lines, update_line)
    new_data = map(new_lines, function(line) return split_string(line, ",") end)
    csv_write(filename, new_data)
end

-- Log instead of print so I can tail
function log(msg)
    local logfile = os.getenv("HOME") .. "/nvim.log"
    if not file_exists(logfile) then
        local file = io.open(logfile, "w")
        file:write("Initializing log\n")
        file:close()
        return
    end
    local file = io.open(logfile, "a")
    file:write(msg .. "\n")
    file:close()
    return
end

-- When a symbol's line number is below the current line and we do something,
-- say, enter insert mode or delete a line, we know we'll want to update that
-- symbol's location. It's fine for the most part if the modification is on the
-- same line, but I have issues when
--
function symbol_should_move(current_line_num, symbol_line_num)
    return current_line_num <= symbol_line_num
end

-- Function for making sure we have a minimum number of separators in a string
-- concat. This makes sure that we have the correct number of fields in our csv
-- if we write 3 or 2 items. Consider the array {"myfile", 4}. We want that to
-- be written as "myfile,4," in the csv, not "myfile,4".
function min_concat_two(array)
    local res = table.concat(array, ",")
    if #array == 1 then res = res .. ",," end
    if #array == 2 then res = res .. "," end
    return res
end

-- Exporting for module use
local M = {}

M.map = map
M.iter_to_table = iter_to_table
M.read_file = read_file
M.split_string = split_string
M.pprint = pprint
M.fprint = fprint
M.file_exists = file_exists
M.arrays_to_table = arrays_to_table
M.csv_read = csv_read
M.csv_read_or_create = csv_read_or_create
M.csv_write = csv_write
M.csv_append = csv_append
M.filter = filter
M.csv_remove_line_by_columns_from_csv = csv_remove_line_by_columns_from_csv
M.csv_update_line_by_columns_from_csv = csv_update_line_by_columns_from_csv
M.log = log
M.symbol_should_move = symbol_should_move
M.min_concat_two = min_concat_two

return M
