--
-- find rational approximation to given real number
-- David Eppstein / UC Irvine / 8 Aug 1993
--
-- With corrections from Arno Formella, May 2008
-- Translation to Lua by Keith Kyzivat, Oct 2014
--
-- usage: lua rational-approximation-cmdline.lua r d
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

function toFraction(startValue, maxdenominator)
    -- Double vars from C
    local x = startValue
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
    local error = startValue - (m[1][1] / m[2][1])
    table.insert(result, { m[1][1], m[2][1], error })

    -- now try other possibility
    ai = (maxdenominator - m[2][2]) / m[2][1]
    m[1][1] = m[1][1] * ai + m[1][2]
    m[2][1] = m[2][1] * ai + m[2][2]
    error = startValue - (m[1][1] / m[2][1])
    table.insert(result, { m[1][1], m[2][1], error })

    return result
end

