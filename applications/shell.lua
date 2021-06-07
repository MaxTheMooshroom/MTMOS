local Program = {}

local screen_buffer = {}
local scroll_offset = 0
local input_buffer = ''
local input_offset = 0

local should_draw = true

local function parse()
    -- do something with input_buffer and screen_buffer
    input_buffer = ''
    input_offset = 0
    should_draw = true
end

function Program.Info()
    Program.container.name = 'mtmos-shell'
    Program.container.name_pretty = 'Shell'
end

function Program.Main()
    coroutine.yield()
    while true do
        local _event = Program.container.eq:pop()
        if _event ~= nil then
            if _event.type == 'char' then
                local diff = string.len(input_buffer) - input_offset
                input_buffer = string.sub(input_buffer, 1, diff) .. _event.p1 .. string.sub(input_buffer, diff+1)
                local _, height = term.getSize()
                term.setCursorPos(2 + string.len(input_buffer) - input_offset + 1, height)
                term.setCursorBlink(true)

            elseif _event.type == 'key' then
                -- left arrow key; don't go too far left
                if _event.p1 == 203 and input_offset ~= string:len(input_buffer) then
                    input_offset = input_offset + 1
                    local _, height = term.getSize()
                    term.setCursorPos(2 + string.len(input_buffer) - input_offset + 1, height)
                    term.setCursorBlink(true)

                -- right arrow key; don't go too far right
                elseif _event.p1 == 205 and input_offset ~= 0 then
                    input_offset = input_offset - 1
                    local _, height = term.getSize()
                    term.setCursorPos(2 + string.len(input_buffer) - input_offset + 1, height)
                    term.setCursorBlink(true)

                -- backspace key; don't go too far to the left
                elseif _event.p1 == 14 then
                    input_offset = input_offset - 1
                    local diff = string.len(input_buffer) - input_offset
                    input_buffer = string.sub(input_buffer, 1, diff) .. _event.p1 .. string.sub(input_buffer, diff+2)
                    local _, height = term.getSize()
                    term.setCursorPos(2 + string.len(input_buffer) - input_offset + 1, height)
                    term.setCursorBlink(true)

                -- enter key
                elseif _event.p1 == 28 then
                    parse()
                end
            end
        end
        coroutine.yield()
    end
end

function Program.Draw(_P)
    while true do
        --io.write('.')
        -- if should_draw == true then
        -- TODO print screen buffer
        -- term.clear()
        term.setCursorBlink(false)
        local x, y = term.getCursorPos()
        local _, height = term.getSize()
        term.setCursorPos(1, height)
        printf('&6$ ', '\0')
        io.write(input_buffer)
        term.setCursorBlink(true)
        term.setCursorPos(x, y)
        -- tableutils.dump({
        --         input_buffer = input_buffer
        --     },
        --     "draw.data"
        -- )
        -- end
        coroutine.yield()
    end
end

return Program
