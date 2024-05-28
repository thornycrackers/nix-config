-- Module for persisting qfnotes data to disk.
--
-- Function for serializing a lua table to a file
-- It's meant to handle a simple use case of serializing a k,v table where both
-- are strings.
local db_file = os.getenv("HOME") .. "/.qfnotes.lua"

function serialize_table_to_file(t, filename)

    local function serialize(o)
        local result = "{"
        for k, v in pairs(o) do
            result = result .. "[" .. string.format("%q", k) .. "]=" ..
                         string.format("%q", v) .. ","
        end
        return result .. "}"
    end

    local file, err = io.open(filename, "w")
    if not file then error("Could not open file for writing: " .. err) end

    file:write("return " .. serialize(t))
    file:close()
end

-- Function to load a Lua table from a file
function load_table_from_file(filename)
    local func, err = loadfile(filename)
    if not func then error("Failed to load table from file: " .. err) end
    return func()
end

-- Function to load a lua table from a file but will create the file if it doesn't already exist
function load_or_create_table_from_file(filename)
    if not file_exists(filename) then
        local file = io.open(filename, "w")
        file:write("return {}")
        file:close()
    end
    return load_table_from_file(filename)
end

function get_table() return load_or_create_table_from_file(db_file) end
function set_table(t) return serialize_table_to_file(t, db_file) end
function update_table(k, v)
    t = get_table()
    t[k] = v
    set_table(t)
end
function remove_key(k)
    t = get_table()
    t[k] = nil
    set_table(t)
end

local M = {}

M.get_table = get_table
M.set_table = set_table
M.update_table = update_table
M.remove_key = remove_key

return M
