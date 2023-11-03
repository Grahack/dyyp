local main_file = 'dyyp.lua'
dofile(main_file)

-- utils
function show(tbl)
    for _, v in ipairs(tbl) do
        print(v)
    end
end
-- end of utils

-- grab the relevant lines: they begin with "--dt"
-- organise them in a table, keys being the names of the functions
local f_name = nil
local tests = {}
local tests_tmp = {}
local doctest_prefix = '--dt '
for line in io.lines(main_file) do
    -- try to grab a function name
    local s = string.match(line, "function ([^(]*)")
    if s ~= nil then
        if f_name ~= nil then
            tests[f_name] = tests_tmp
        end
        f_name = s
        tests_tmp = {}
    end
    -- grab the tests in this function
    local s = string.match(line, "--dt (.*)")  -- /!\ - is a control char
    if s ~= nil then
        tests_tmp[#tests_tmp + 1] = s
    end
end
-- tests of the last function
tests[f_name] = tests_tmp

-- parse and check the doc tests
for f_name, f_tests in pairs(tests) do
    for _, test in ipairs(tests[f_name]) do
        local args_str, expected_str = string.match(test, "(.*) => (.*)")
        local test_str = f_name..'('..args_str..') == ' .. expected_str
        local test_f, e = load('return '..test_str)
        if test_f == nil then print(e) end
        if not test_f() then
            print(test_str .. ' is false!')
            local the_call = f_name..'('..args_str..')'
            print('The call returned '..load('return '..the_call)()..'.')
        end
    end
end
