require("modules/utils")
require("events")
require("screen")

local args = {...} -- cli arguments, if any

do
    local h = fs.open("rom/modules/main/cc/expect.lua", "r")
    local f, err = loadstring(h.readAll(), "@expect.lua")
    h.close()

    if not f then error(err) end
    _G.expect = f().expect
end

function main()
    local _p = Programs.open('MTMOS/applications/shell.lua')
    --print(tableutils.to_string(PROGRAM_LIST))
    Programs.setFocusedProgram(_p)
    parallel.waitForAny(Programs.renderFocused, Programs.tick, Events.poll)
end

main()
