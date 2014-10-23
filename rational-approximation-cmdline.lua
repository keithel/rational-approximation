require "rational-approximation"

-- read command line arguments
if (#arg ~= 2) then
    io.stderr:write("usage: lua fractions.lua r d\n") -- AF: argument missing
    os.exit(1)
end

local fracs = toFraction(tonumber(arg[1]), math.floor(tonumber(arg[2])))
io.write("Results:\n")
io.write(string.format("  (1) %5d/%-5d    error %13e\n", fracs[1][1], fracs[1][2], fracs[1][3]))
io.write(string.format("  (2) %5d/%-5d    error %13e\n", fracs[2][1], fracs[2][2], fracs[2][3]))
