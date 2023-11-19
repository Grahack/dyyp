local main_file = 'dyyp.lua'
dofile(main_file)

-- utils
function table_tostring(tbl)
    local ts = tostring(tbl)
    if string.sub(ts, 1, 5) ~= 'table' then return ts end
    local r = '{'
    for i=1, #tbl do
        r = r .. tbl[i]
        if i ~= #tbl then r = r .. ', ' end
    end
    r = r .. '}'
    return r
end

-- compares strings, numbers and tables which are arrays
function compare(a, b)
    if type(a) == 'number' and type(b) == 'number' then return a == b end
    if type(a) == 'string' and type(b) == 'string' then return a == b end
    if type(a) == 'table' and type(b) == 'table' then
        if #a ~= #b then return false
        else
            for i, _ in pairs(a) do
                if a[i] ~= b[i] then return false end
            end
        end
        return true
    end
    return false
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
    local pos = string.find(line, doctest_prefix, 1, true)  -- true for plain
    if pos ~= nil then
        tests_tmp[#tests_tmp + 1] = string.sub(line, pos + #doctest_prefix)
    end
end
-- tests of the last function
tests[f_name] = tests_tmp

local verbose = false  -- may be used to generate documentation
local verbose_tests = {}

-- parse and check the doc tests
for f_name, f_tests in pairs(tests) do
    if verbose and #tests[f_name] > 0 then
        verbose_tests[#verbose_tests+1] = "- " .. f_name  -- for the TOC
        verbose_tests[#verbose_tests+1] = f_name
    end
    for _, test in ipairs(tests[f_name]) do
        local args_str, expected_str = string.match(test, "(.*) => (.*)")
        if expected_str == nil then print("Malformed test: "..test) end
        local A_str = f_name..'('..args_str..')'
        local B_str = expected_str
        local test_str = 'compare(' .. A_str .. ', ' .. B_str .. ')'
        if verbose then
            verbose_tests[#verbose_tests+1] = A_str .. ' => ' .. B_str
        end
        local test_f, e = load('return '..test_str)
        if test_f == nil then print(e) end
        if not test_f() then
            print(A_str .. ' == ' .. B_str .. ' is false!')
            local the_call = f_name..'('..args_str..')'
            local result = load('return '..the_call)()
            if result == nil then result = "nil" end
            if type(result) == 'table' then result = table_tostring(result) end
            print('The call returned '..result..'.')
        end
    end
end

if verbose then
    table.sort(verbose_tests)
    for _, v in ipairs(verbose_tests) do
        print(v)
    end
end
