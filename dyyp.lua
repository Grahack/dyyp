-- DyyP, a Lua library about music theory

-- The constants

-- Syntactic sugar for note names
A, B, C, D, E, F, G = "A", "B", "C", "D", "E", "F", "G"

-- Generate notes (constant MIDI nums) as global variables
-- Cf0, Cb0, Dob0 eval to 11 (English and French names)
-- C0, Do0 eval to 12
-- ...
-- We use a trick about multiple-assignment
-- https://stackoverflow.com/questions/10842679/lua-multiple-assignment
-- These chars not available in var names: é # ♯ ♭
function multi(n)
    -- Utility
    return n, n, n, n, n
end
for i = 0, 9, 1 
do 
   -- Beware: Cf1 is B0
   _G["Cf" ..i], _G["Cb"  ..i], _G["Dob"..i]                 = multi(11 + 12*i)
   _G["C"  ..i], _G["Do"  ..i]                               = multi(12 + 12*i)
   _G["Cs" ..i], _G["Dod" ..i],
                 _G["Db"  ..i], _G["Df" ..i], _G["Reb" ..i]  = multi(13 + 12*i)
   _G["C2s"..i], _G["Do2d"..i],
                 _G["D"   ..i], _G["Re" ..i],
                 _G["Ebb" ..i], _G["Eff"..i], _G["Mibb"..i]  = multi(14 + 12*i)
   _G["Ds" ..i], _G["Red" ..i],
                 _G["Eb"  ..i], _G["Ef" ..i], _G["Mib" ..i]  = multi(15 + 12*i)
   _G["E"  ..i], _G["Mi"  ..i],
                 _G["Ff"  ..i], _G["Fb" ..i], _G["Fab" ..i]  = multi(16 + 12*i)
   _G["Es" ..i], _G["Mid" ..i], _G["F"  ..i], _G["Fa"  ..i]  = multi(17 + 12*i)
   _G["Fs" ..i], _G["Fad" ..i],
                 _G["Gb"  ..i], _G["Gf" ..i], _G["Solb"..i]  = multi(18 + 12*i)
   _G["F2s"..i], _G["Fa2d"..i], _G["G"  ..i], _G["Sol" ..i]  = multi(19 + 12*i)
   _G["Gs" ..i], _G["Sold"..i],
                 _G["Ab"  ..i], _G["Af" ..i], _G["Lab" ..i]  = multi(20 + 12*i)
   _G["A"  ..i], _G["La"  ..i],
                 _G["Bbb" ..i], _G["Bff"..i], _G["Sibb"..i]  = multi(21 + 12*i)
   _G["As" ..i], _G["Lad" ..i],
                 _G["Bb"  ..i], _G["Bf" ..i], _G["Sib" ..i]  = multi(22 + 12*i)
   _G["B"  ..i], _G["Si"  ..i],
                 _G["Cf"  ..i],  _G["Cb"..i], _G["Dob" ..i]  = multi(23 + 12*i)
   -- Beware: Bs0 is C1
   _G["Bs"..i], _G["Sid"  ..i]                               = multi(24 + 12*i)
   -- Last MIDI num is 127 (G9) but here we have some more: Bs9 is 132
end
multi = nil

-- The functions
-- Note: dt comments are doctests
-- Note: "Utility" are non musical functions

function note_name_and_oct_to_midi(name, oct)
    --dt 'A', 4 => 69
    --dt A, 4 => 69
    local f = load('return '..name..oct)
    return f()
end

function offset_in_circle(pos, len, inc)
    -- Utility
    -- Say we have a circle of numbers from 1 to len,
    -- what is the new position of pos after an increment of inc?
    --dt 1, 7, 1 => 2
    --dt 7, 7, 1 => 1
    return (pos - 1 + inc) % 7 + 1
end

function next_name(name)
    --dt A => B
    --dt G => A
    local names = "ABCDEFG"
    local pos = offset_in_circle(string.find(names, name), 7, 1)
    return string.sub(names, pos, pos)
end

function previous_name(name)
    --dt B => A
    --dt A => G
    local names = "ABCDEFG"
    local pos = offset_in_circle(string.find(names, name), 7, -1)
    return string.sub(names, pos, pos)
end

function third_name(name)
    --dt A => C
    --dt G => B
    return next_name(next_name(name))
end

function fourth_name(name)
    --dt A => D
    --dt G => C
    return next_name(third_name(name))
end

function seventh_name(name)
    --dt B => A
    --dt A => G
    return previous_name(name)
end

function sixth_name(name)
    --dt B => G
    --dt A => F
    return previous_name(seventh_name(name))
end

function fifth_name(name)
    --dt A => E
    --dt G => D
    return previous_name(sixth_name(name))
end
