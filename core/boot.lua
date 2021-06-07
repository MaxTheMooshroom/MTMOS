require("modules/utils")
require("events")

local args = {...} -- cli arguments, if any

do
    local h = fs.open("rom/modules/main/cc/expect.lua", "r")
    local f, err = loadstring(h.readAll(), "@expect.lua")
    h.close()

    if not f then error(err) end
    _G.expect = f().expect
end

function main()
    Programs.open('MTMOS/applications/shell.lua')
    Programs.setFocusedProgram(Programs.findByName("mtmos-shell"))
    parallel.waitForAny(Programs.renderFocused, Programs.tick, Events.poll)
end

main()
