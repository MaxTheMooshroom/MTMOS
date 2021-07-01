require("modules/utils")
require("events")
require("screen")

_G.OSNAME = "MTMOS"
_G.OSVERSION = "0.2.0A"

local args = {...} -- cli arguments, if any

-- MTMOS shouldn't fall back to CraftOS when there's an error unless that is
-- explicitly defined behavior or there's an error in MTMOS.
_G._error = error
function _G.error(text)
    io.write(text)
end

local function terminator(_event)
    exit()
end
Events.addListener('terminate', terminator)

function main()
    local shell_program = Programs.open('MTMOS/applications/shell.lua')
    Programs.setFocusedProgram(shell_program)
    _G._shell = shell
    _G.shell = shell_program

    parallel.waitForAny(Programs.renderFocused, Programs.tick, Events.poll)
end

main()
