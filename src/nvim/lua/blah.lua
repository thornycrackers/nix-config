package.path = os.getenv("HOME") .. "/.nixpkgs/src/nvim/lua/?.lua;" ..
                   package.path
-- -- Import the utils file
local lib = require('qfnotes_lib')
-- local map = qfnotes_utils.map
-- local iter_to_table = qfnotes_utils.iter_to_table
-- local pprint = qfnotes_utils.print_table
-- local split = qfnotes_utils.split_string
--
f = loadfile("asdfasdf.lua")
local res = f()
lib.pprint(res)
