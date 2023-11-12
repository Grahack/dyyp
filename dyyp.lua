-- DyyP, a Lua library about music theory

-- The constants

-- Syntactic sugar for note names
A, B, C, D, E, F, G = "A", "B", "C", "D", "E", "F", "G"
Ab, Bb, Cb, Db, Eb, Fb, Gb = "Ab", "Bb", "Cb", "Db", "Eb", "Fb", "Gb"
Af, Bf, Cf, Df, Ef, Ff, Gf = "Ab", "Bb", "Cb", "Db", "Eb", "Fb", "Gb"
As, Bs, Cs, Ds, Es, Fs, Gs = "As", "Bs", "Cs", "Ds", "Es", "Fs", "Gs"
La, Si, Do, Re, Mi, Fa, Sol = "La", "Si", "Do", "Re", "Mi", "Fa", "Sol"
Lab, Sib, Dob, Reb, Mib, Fab, Solb =
    "Lab", "Sib", "Dob", "Reb", "Mib", "Fab", "Solb"
Lad, Sid, Dod, Red, Mid, Fad, Sold =
    "Lad", "Sid", "Dod", "Red", "Mid", "Fad", "Sold"
C2s, Do2d, Ebb, Eff, Mibb, F2s, Fa2d, Bbb, Bff, Sibb =
    "C2s", "Do2d", "Ebb", "Eff", "Mibb", "F2s", "Fa2d", "Bbb", "Bff", "Sibb"

-- Generate notes (constant MIDI nums) as global variables
-- Cf0, Cb0, Dob0 eval to 11 (English and French names)
-- C0, Do0 eval to 12
-- ...
-- We use a trick about multiple-assignment
-- https://stackoverflow.com/questions/10842679/lua-multiple-assignment
-- These chars not available in var names: é # ♯ ♭
function multi(n)
    -- Utility
    return n, n, n, n, n, n, n
end
for i = 0, 9, 1 
do 
   -- Beware: Cf1 is B0
   _G[Cf ..i], _G[Cb  ..i], _G[Dob..i]              = multi(11 + 12*i)
   _G[C  ..i], _G[Do  ..i]                          = multi(12 + 12*i)
   _G[Cs ..i], _G[Dod ..i],
               _G[Db  ..i], _G[Df ..i], _G[Reb ..i] = multi(13 + 12*i)
   _G[C2s..i], _G[Do2d..i],
               _G[D   ..i], _G[Re ..i],
               _G[Ebb ..i], _G[Eff..i], _G[Mibb..i] = multi(14 + 12*i)
   _G[Ds ..i], _G[Red ..i],
               _G[Eb  ..i], _G[Ef ..i], _G[Mib ..i] = multi(15 + 12*i)
   _G[E  ..i], _G[Mi  ..i],
               _G[Ff  ..i], _G[Fb ..i], _G[Fab ..i] = multi(16 + 12*i)
   _G[Es ..i], _G[Mid ..i], _G[F  ..i], _G[Fa  ..i] = multi(17 + 12*i)
   _G[Fs ..i], _G[Fad ..i],
               _G[Gb  ..i], _G[Gf ..i], _G[Solb..i] = multi(18 + 12*i)
   _G[F2s..i], _G[Fa2d..i], _G[G  ..i], _G[Sol ..i] = multi(19 + 12*i)
   _G[Gs ..i], _G[Sold..i],
               _G[Ab  ..i], _G[Af ..i], _G[Lab ..i] = multi(20 + 12*i)
   _G[A  ..i], _G[La  ..i],
               _G[Bbb ..i], _G[Bff..i], _G[Sibb..i] = multi(21 + 12*i)
   _G[As ..i], _G[Lad ..i],
               _G[Bb  ..i], _G[Bf ..i], _G[Sib ..i] = multi(22 + 12*i)
   _G[B  ..i], _G[Si  ..i],
               _G[Cf  ..i], _G[Cb ..i], _G[Dob ..i] = multi(23 + 12*i)
   -- Beware: Bs0 is C1
   _G[Bs..i], _G[Sid  ..i]                          = multi(24 + 12*i)
   -- Last MIDI num is 127 (G9) but here we have some more: Bs9 is 132
end
multi = nil

-- The functions
-- Note: dt comments are doctests
-- Note: "Utility" are non musical functions

function MIDI_diff(name1, name2)
    -- Returns numbers between -6 and 6, see the tests.
    -- Nothing has been done for deciding between -6 or 6, but anyway it
    -- should only be used for small intervals (< 6 semitones).
    -- Only handle note names without octave specification!
    -- If you have the octave just use the minus sign: A5-A4 => 12.
    --dt B , C => -1
    --dt C , B =>  1
    --dt A,  G =>  2
    --dt A,  A =>  0
    --dt As, A =>  1
    --dt Ab, A => -1
    return (_G[name1..0] - _G[name2..0] + 6) % 12 - 6
end

function name_and_alteration(name)
    --dt A  => A, 0
    --dt Ab => A, -1
    --dt As => A, 1
    --dt La  => La, 0
    --dt Lab => La, -1
    --dt Lad => La, 1
    local c = string.sub(name, 1, 1)
    -- First and only letter is enough to identify the name
    if string.find("ABCEG", c) then return c, MIDI_diff(name, c) end
    -- First letter is enough to identify the name
    if string.find("LMR", c) then
        if c == 'L' then return La, MIDI_diff(name, La) end
        if c == 'M' then return Mi, MIDI_diff(name, Mi) end
        if c == 'R' then return Re, MIDI_diff(name, Re) end
    end
    if name == D   then return D,   MIDI_diff(name, D) end
    if name == Do  then return Do,  MIDI_diff(name, Do) end
    if name == F   then return F,   MIDI_diff(name, F) end
    if name == Fa  then return Fa,  MIDI_diff(name, Fa) end
    if name == Si  then return Si,  MIDI_diff(name, Si) end
    if name == Sol then return Sol, MIDI_diff(name, Sol) end
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
    --dt La => Si
    --dt Sol => La
    local names = "ABCDEFG"
    local found = string.find(names, name)
    if found then
        local pos = offset_in_circle(found, 7, 1)
        return string.sub(names, pos, pos)
    end
    local names = {Do, Re, Mi, Fa, Sol, La, Si}
    for i=1, #names do
        if names[i] == name then
            local pos = offset_in_circle(i, 7, 1)
            return names[pos]
        end
    end
end

-- TODO: refactor with previous one
function previous_name(name)
    --dt B => A
    --dt A => G
    --dt Si => La
    --dt La => Sol
    local names = "ABCDEFG"
    local found = string.find(names, name)
    if found then
        local pos = offset_in_circle(found, 7, -1)
        return string.sub(names, pos, pos)
    end
    local names = {Do, Re, Mi, Fa, Sol, La, Si}
    for i=1, #names do
        if names[i] == name then
            local pos = offset_in_circle(i, 7, -1)
            return names[pos]
        end
    end
end

function second_name(name)
    --dt A => B
    --dt G => A
    --dt La => Si
    --dt Sol => La
    return next_name(name)
end

function third_name(name)
    --dt A => C
    --dt G => B
    --dt La => Do
    --dt Sol => Si
    return next_name(next_name(name))
end

function fourth_name(name)
    --dt A => D
    --dt G => C
    --dt La => Re
    --dt Sol => Do
    return next_name(third_name(name))
end

function seventh_name(name)
    --dt B => A
    --dt A => G
    --dt Si => La
    --dt La => Sol
    return previous_name(name)
end

function sixth_name(name)
    --dt B => G
    --dt A => F
    --dt Si => Sol
    --dt La => Fa
    return previous_name(seventh_name(name))
end

function fifth_name(name)
    --dt A => E
    --dt G => D
    --dt La => Mi
    --dt Sol => Re
    return previous_name(sixth_name(name))
end
