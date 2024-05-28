-- Define the CodeNote class
CodeNote = {}
CodeNote.__index = CodeNote

-- Constructor
function CodeNote:new(filepath, line_number, contents)
    local instance = setmetatable({}, self)
    instance.filepath = filepath
    instance.line_number = line_number
    instance.contents = contents
    return instance
end

-- Method to print the codenote
function CodeNote:print()
    local res = "CodeNote("
    res = res .. self.filepath .. ", "
    res = res .. self.line_number .. ", "
    res = res .. self.contents .. ")"
    print(res)
end

-- Method to convert a code note into a vim quicklist item
-- I don't know if this is the best place to put the logic, but it sure is the
-- easiest.
function CodeNote:to_quicklist_item()
    local res = {
        filename = self.filepath,
        lnum = self.line_number,
        col = 0,
        text = self.contents
    }
    return res
end

function CodeNote:get_filepath() return self.filepath end
function CodeNote:get_line_number() return self.line_number end
function CodeNote:get_contents() return self.contents end
function CodeNote:get_value() return self.contents end
function CodeNote:get_key() return self.filepath .. "::" .. self.line_number end

return CodeNote
