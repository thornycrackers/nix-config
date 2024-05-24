-- All kinds of little utils that I split up for unit testing
local M = {}

-- Map function
function M.map(tbl, f)
    local t = {}
    for k, v in pairs(tbl) do t[k] = f(v) end
    return t
end

-- Iterator to table
function M.iter_to_table(iter)
    local t = {}
    for v in iter do table.insert(t, v) end
    return t
end

-- Simple function for reading a file
function M.read_file(file_path)
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
function M.split_string(input_string, delimiter)
    local parts = {}
    for part in input_string:gmatch("[^" .. delimiter .. "]+") do
        table.insert(parts, part)
    end
    return parts
end

-- Generic function for printing a table for debugging purposes
function M.print_table(table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            print(key .. ": {")
            M.print_table(value)
            print("}")
        else
            print(key .. ": " .. tostring(value))
        end
    end
end

-- Check whether a file exists or not
function M.file_exists(file_path)
    local file = io.open(file_path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

-- Create a table from two arrays
function M.arrays_to_table(array1, array2)
    local length = math.min(#array1, #array2)
    local result = {}
    for i = 1, length do result[array1[i]] = array2[i] end
    return result
end

-- Read a csv file
function M.csv_read(filename)
    local lines = M.read_file(filename)
    local headers = M.split_string(lines[1], ",")
    local res = {}
    for i = 2, #lines do
        values = M.split_string(lines[i], ",")
        table.insert(res, M.arrays_to_table(headers, values))
    end
    return res
end

-- Read a csv, create if doesn't exist
function M.csv_read_or_create(filename, headers)
    if not M.file_exists(filename) then
        local file = io.open(filename, "w")
        file:write(headers .. "\n")
        file:close()
        return {}
    end
    return M.csv_read(filename)
end

-- Write a csv file
function M.csv_write(filename, data)
    local file = io.open(filename, "w")
    if file then
        for _, item in ipairs(data) do
            file:write(table.concat(item, ",") .. "\n")
        end
        file:close()
    else
        error("Error: Unable to open file for writing.")
    end
end

-- Append a csv file
function M.csv_append(filename, data)
    local file = io.open(filename, "a")
    if file then
        for _, row in ipairs(data) do
            file:write(table.concat(row, ",") .. "\n")
        end
        file:close()
    else
        error("Error: Unable to open file " .. filename .. " for appending.")
    end
end

-- Filter an array via a function
function M.filter(array, predicate)
    local res = {}
    for _, v in ipairs(array) do
        if predicate(v) then table.insert(res, v) end
    end
    return res
end

-- Function to remove a line based on matching values in two columns from a CSV file
-- TODO: This is being refactored via the old method signature. Clean up later cause ugly
function M.csv_remove_line_by_columns_from_csv(filename, column1Value,
                                               column2Value)
    -- This function will keep the lines that don't match the one we're looking for
    -- It's janky because it deletes from a csv file based on the first two
    -- column values which are a unique ID in our case consisting of "filepath" and "line number"
    local function keep_line(line)
        prefix = column1Value .. "," .. column2Value .. ","
        return line:sub(1, #prefix) ~= prefix
    end
    local lines = M.read_file(filename)
    local new_lines = M.filter(lines, keep_line)
    new_data = M.map(new_lines,
                     function(line) return M.split_string(line, ",") end)
    M.csv_write(filename, new_data)
end

-- Function to update a csv file based on the first two column values
-- TODO: This is being refactored via the old method signature. Clean up later cause ugly
function M.csv_update_line_by_columns_from_csv(filename, column1Value,
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
    local lines = M.read_file(filename)
    local new_lines = M.map(lines, update_line)
    new_data = M.map(new_lines,
                     function(line) return M.split_string(line, ",") end)
    M.csv_write(filename, new_data)
end

return M
