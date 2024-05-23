local qfnotes_utils = require('qfnotes_utils')

describe('Busted unit testing framework', function()
    describe('should be awesome', function()

        it('should be able to import and use qfnotes_utils', function()
            local res = qfnotes_utils.return_true()
            assert.truthy(res)
        end)

        it('should be able to read a csv file', function()
            local tmpfile = os.tmpname()
            local file = io.open(tmpfile, "w") -- Open the file in write mode
            file:write("header1,header2" .. "\n")
            file:write("value1,value2" .. "\n")
            file:close()
            local res = qfnotes_utils.csv_read(tmpfile)
            assert.same(res, {[1] = { ['header1'] = 'value1', ['header2'] = 'value2' }})
        end)

    end)
end)
