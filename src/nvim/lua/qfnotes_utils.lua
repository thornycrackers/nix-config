local M = {}

function M.return_true()
    return true
end

function M.csv_read(filename)
    local file = io.open(filename, "r") -- Open the file in read mode
    if not file then
        print("Error opening the file for reading.")
        return nil
    end
    local data = {}
    local headers = {}
    local header_line = file:read()
    if header_line then
        for header in header_line:gmatch("([^,]+),") do
            table.insert(headers, header)
        end
        table.insert(headers, header_line:match("([^,]+)$"))
    else
        print("Error reading header line.")
        file:close()
        return nil
    end
    for line in file:lines() do
        local row = {}
        local column_index = 1
        for value in line:gmatch("([^,]+),") do
            row[headers[column_index]] = value
            column_index = column_index + 1
        end
        row[headers[column_index]] = line:match("([^,]+)$")
        table.insert(data, row)
    end
    file:close()
    return data
end

return M
