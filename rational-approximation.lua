--
-- find rational approximation to given real number
-- David Eppstein / UC Irvine / 8 Aug 1993
--
-- With corrections from Arno Formella, May 2008
-- Translation to Lua by Keith Kyzivat, Oct 2014
--
-- usage: lua rational-approximation.lua r d
--   r is real number to approx
--   d is the maximum denominator allowed
--
-- based on the theory of continued fractions
-- if x = a1 + 1/(a2 + 1/(a3 + 1/(a4 + ...)))
-- then best approximation is found by truncating this series
-- (with some adjustments in the last term).
--
-- Note the fraction can be recovered as the first column of the matrix
--  ( a1 1 ) ( a2 1 ) ( a3 1 ) ...
--  ( 1  0 ) ( 1  0 ) ( 1  0 )
--
-- Instead of keeping the sequence of continued fraction terms,
-- we just keep the last partial product of these matrices.
--

function toFraction(startx, maxdenominator)
    -- Double vars from C
    local x = startx
    -- Long vars from C
    local ai = math.floor(x)
    local result = {}

    local m = {} -- multidimentional array of longs
    for i = 1,2 do
        m[i] = {} -- Create 2 rows.
    end

    -- initialize matrix
    m[1][1] = 1
    m[1][2] = 0
    m[2][1] = 0
    m[2][2] = 1

    -- loop finding terms until denominator gets too big
    while (m[2][1] * ai + m[2][2] <= maxdenominator) do
        local t -- long
        t = m[1][1] * ai + m[1][2]
        m[1][2] = m[1][1]
        m[1][1] = t
        t = m[2][1] * ai + m[2][2]
        m[2][2] = m[2][1]
        m[2][1] = t
        if (x==ai) then break end     -- AF: division by zero
        x = 1/(x - ai)
        if x>0x7FFFFFFF then break end  -- AF: representation failure

        ai = math.floor(x)
    end

    -- now remaining x is between 0 and 1/ai
    -- approx as either 0 or 1/m where m is max that will fit in maxdenominator
    -- first try zero
    local error = startx - (m[1][1] / m[2][1])
    table.insert(result, { m[1][1], m[2][1], error })

    -- now try other possibility
    ai = (maxdenominator - m[2][2]) / m[2][1]
    m[1][1] = m[1][1] * ai + m[1][2]
    m[2][1] = m[2][1] * ai + m[2][2]
    error = startx - (m[1][1] / m[2][1])
    table.insert(result, { m[1][1], m[2][1], error })

    return result
end

-- read command line arguments
if (#arg ~= 2) then
    io.stderr:write("usage: lua fractions.lua r d\n") -- AF: argument missing
    os.exit(1)
end

local fracs = toFraction(tonumber(arg[1]), math.floor(tonumber(arg[2])))
io.write("Results:\n")
io.write(string.format("  (1) %5d/%-5d    error %13e\n", fracs[1][1], fracs[1][2], fracs[1][3]))
io.write(string.format("  (2) %5d/%-5d    error %13e\n", fracs[2][1], fracs[2][2], fracs[2][3]))
