local argser = dofile("argser")

local parser = argser(...)
parser:named("mode", true, "string")
parser:named("device", true, "string")
parser:named("file", true, "string")
parser:named("wireless")
parser:parse()

local args = parser.args

function printUsage ()
    print("Usage: ftp <mode> <device> <file> [optional: wireless]")
end

if args[1] == "fetch" then
    print("fetching " .. args[3] .. " from " .. args[2] .. "...")
    print("Not yet implemented")
elseif args[1] == "send" then
    print("sending " .. args[3] .. " to " .. args[2] .. "...")
    print("Not yet implemented")
else
    print("Mode can only be \"fetch\" or \"send\"")
    printUsage()
end
