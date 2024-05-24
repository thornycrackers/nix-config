local qfnotes_utils = require('qfnotes_utils')

describe('qfntoes_utils testing', function()
    describe('should be awesome', function()

        it('should be able to detect if a file exists', function()
            local tmpfile = os.tmpname()
            local file = io.open(tmpfile, "w") -- Open the file in write mode
            file:write(" ")
            file:close()
            assert.is_true(qfnotes_utils.file_exists(tmpfile))
            assert.is_false(qfnotes_utils.file_exists("file_that_doesnt_exists.csv"))
        end)

        it('should throw an error if the file doesnt exist', function()
            assert.has_error(function() qfnotes_utils.csv_read("file_that_doesnt_exist.csv") end)
        end)

        it('should be able to read a csv', function()
            local tmpfile = os.tmpname()
            local file = io.open(tmpfile, "w")
            file:write("header1,header2" .. "\n")
            file:write("value1,value2" .. "\n")
            file:close()
            local res = qfnotes_utils.csv_read(tmpfile)
            assert.same(res, {[1] = { ['header1'] = 'value1', ['header2'] = 'value2' }})
        end)

        it('should be able to write a csv', function()
            local tmpfile = os.tmpname()
            local data = {{"header1", "header2"}, {"value1", "value2"}}
            local res = qfnotes_utils.csv_write(tmpfile, data)
            local res = qfnotes_utils.csv_read(tmpfile)
            assert.same(res, {[1] = { ['header1'] = 'value1', ['header2'] = 'value2' }})
        end)

        it('should be able to append to a csv', function()
            local tmpfile = os.tmpname()
            local data = {{"header1", "header2"}, {"value1", "value2"}}
            local res = qfnotes_utils.csv_write(tmpfile, data)
            local new_data = {{"value3", "value4"}}
            qfnotes_utils.csv_append(tmpfile, new_data)
            local res = qfnotes_utils.csv_read(tmpfile)
            assert.same(res, {
                [1] = { ['header1'] = 'value1', ['header2'] = 'value2' },
                [2] = { ['header1'] = 'value3', ['header2'] = 'value4' }}
            )
        end)

        it('should be able to split a line', function()
            local line = "1,2,3"
            local res = qfnotes_utils.split_string(line, ",")
            assert.same(res, {"1", "2", "3"})
        end)

        it('should be able to split a list of lines with a map function', function()
            local lines = {"1,2,3", "a,b,c"}
            local res = qfnotes_utils.map(lines, function(line) return qfnotes_utils.split_string(line, ",") end)
            assert.same(res, {
                [1] = {"1", "2", "3"},
                [2] = {"a", "b", "c"},
            })
        end)

        it('should be able to make two arrays into a table', function()
            local array1 = {"a", "b", "c"}
            local array2 = {"d", "e", "f"}
            local res = qfnotes_utils.arrays_to_table(array1, array2)
            assert.same(res, {
                ["a"] = "d",
                ["b"] = "e",
                ["c"] = "f",
            })
        end)


        it('should be able to filter an array', function()
            local array = {1, 2, 3, 4}
            local function is_even(num)
                return num % 2 == 0
            end
            local res = qfnotes_utils.filter(array, is_even)
            assert.same(res, {2, 4})
        end)

        it('should be able to remove a line from a csv', function()
            local tmpfile = os.tmpname()
            local data = {{"header1", "header2"}, {"value1", "value2"}, {"value3", "value4"}}
            qfnotes_utils.csv_write(tmpfile, data)
            qfnotes_utils.csv_remove_line_by_columns_from_csv(tmpfile, "value1", "value2")
            local res = qfnotes_utils.csv_read(tmpfile)
            assert.same(res, {
                [1] = { ['header1'] = 'value3', ['header2'] = 'value4' }}
            )
        end)

        it('should be able to update a line in a csv', function()
            local tmpfile = os.tmpname()
            local data = {{"header1", "header2", "header3"}, {"value1", "value2", "value3"}}
            qfnotes_utils.csv_write(tmpfile, data)
            qfnotes_utils.csv_update_line_by_columns_from_csv(tmpfile, "value1", "value2", "newvalue")
            local res = qfnotes_utils.csv_read(tmpfile)
            assert.same(res, {
                [1] = { ['header1'] = 'value1', ['header2'] = 'value2', ['header3'] = 'newvalue' }}
            )
        end)

        it('should be able read a csv or create it if it doesnt exist', function()
            -- os.tmpname will create a temp file but I don't want the file to
            -- exist yet so I append to the name
            local tmpfile = os.tmpname() .. "notexists"
            local headers = "header1,header2"
            local res = qfnotes_utils.csv_read_or_create(tmpfile, headers)
            assert.same(res, {})
            -- Test normal writing then reading
            local data = {{"header1", "header2"}, {"value1", "value2"}}
            qfnotes_utils.csv_write(tmpfile, data)
            local res = qfnotes_utils.csv_read_or_create(tmpfile, headers)
            assert.same(res, {
                [1] = { ['header1'] = 'value1', ['header2'] = 'value2'}}
            )
        end)

    end)
end)
