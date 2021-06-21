--require("MTMOS/core/screen")

local Program = {}

local screen_buffer = {}
Program.screen_buffer = screen_buffer
screen_buffer.content = {'&6MTMOS V0.2.0A',}
screen_buffer.scroll_offset = 0
screen_buffer.has_changed = false


local previous_input_buffer = 0
local input_buffer = ''
local input_offset = 0

local should_draw = true

local commands = {}
Program.commands = commands
local command_alises = {}

function commands.echo(arguments)
    table.insert(screen_buffer.content, arguments)
end

function commands.run(arguments)
    local args = stringutils.parameterize(arguments)
    local program_location = table.remove(args, 1)
    Programs.open(program_location, args)
end

function commands.clear(arguments)
    screen_buffer.content = {}
    screen_buffer.scroll_offset = 0
    term.clear()
end

function commands.wget(arguments)
    local args = stringutils.parameterize(arguments)
    if #args ~= 2 then
        table.insert(screen_buffer.content, "Usage: &6wget <url> <filename>")
        return
    end

    local request = http_get(args[1])
    local code, msg = request.getResponseCode()
    if msg ~= "OK" then
        table.insert(screen_buffer.content, '&6'..msg)
        return
    end
    local file_contents = request.readAll()
    if fs.exists(args[2]) then
        table.insert(screen_buffer.content, '&6File "'..args[2]..'" already exists')
        return
    end
    local f = fs.open(args[2], 'w')
    f.write(file_contents)
    f.close()
end

function commands.getminer(arguments)
    commands.wget('"https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS-Programs/master/miner/main.lua" "miner.lua"')
end

local function parse()
    table.insert(screen_buffer.content, "&6$ &0"..input_buffer)
    if input_buffer == '' then
        screen_buffer.has_changed = true
        return
    end
    local args = stringutils.parameterize(input_buffer)
    local command = table.remove(args, 1)
    local command_args = stringutils.join(args)
    local func = commands[command] or commands[command_alises[command]]
    if func ~= nil then
        func(command_args)
    else
        table.insert(screen_buffer.content, '&eCommand "'..command..'" not found')
    end
    input_buffer = ''
    input_offset = 0
    screen_buffer.scroll_offset = 0
    screen_buffer.has_changed = true
end

function Program.Info()
    Program.container.name = 'mtmos-shell'
    Program.container.name_pretty = 'Shell'
end

function Program.Main()
    -- INIT
    --screen = Screen.new()
    -- END INIT
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
                if _event.p1 == keys.left and input_offset ~= string.len(input_buffer) then
                    input_offset = input_offset + 1
                    local _, height = term.getSize()
                    term.setCursorPos(2 + string.len(input_buffer) - input_offset + 1, height)
                    term.setCursorBlink(true)

                -- right arrow key; don't go too far right
                elseif _event.p1 == keys.right and input_offset ~= 0 then
                    input_offset = input_offset - 1
                    local _, height = term.getSize()
                    term.setCursorPos(2 + string.len(input_buffer) - input_offset + 1, height)
                    term.setCursorBlink(true)

                -- backspace key; don't go too far to the left
                elseif _event.p1 == keys.backspace and string.len(input_buffer) > 0 and input_offset ~= string.len(input_buffer) then
                    local width, height = term.getSize()
                    if input_offset > string.len(input_buffer) then input_offset = string.len(input_buffer) end
                    local diff = string.len(input_buffer) - input_offset
                    input_buffer = string.sub(input_buffer, 1, diff-1) .. string.sub(input_buffer, diff+1)
                    term.setCursorPos(2 + string.len(input_buffer) - input_offset + 1, height)
                    term.setCursorBlink(true)

                -- enter key
                elseif _event.p1 == keys.enter then
                    local x, y = term.getCursorPos()
                    local width, height = term.getSize()
                    parse()
                    term.setCursorPos(1, height)
                    printf('&6$ '..string.rep(' ', width-2), '\0')
                    term.setCursorPos(x, y)
                -- else
                    -- local x, y = term.getCursorPos()
                    -- term.setCursorPos(1, 1)
                    -- io.write(_event.p1)
                    -- term.setCursorPos(x, y)
                end
            elseif _event.type == 'mouse_scroll' then
                local prev_scroll = screen_buffer.scroll_offset
                local width, height = term.getSize()
                local max_scroll = math.max(0, #screen_buffer.content - (height - 1))
                screen_buffer.scroll_offset = screen_buffer.scroll_offset - _event.p1

                if screen_buffer.scroll_offset < 0 then
                    screen_buffer.scroll_offset = 0
                elseif screen_buffer.scroll_offset > max_scroll then
                    screen_buffer.scroll_offset = max_scroll
                end

                screen_buffer.has_changed = screen_buffer.scroll_offset ~= prev_scroll

            elseif _event.type == 'paste' then
                local diff = string.len(input_buffer) - input_offset
                input_buffer = string.sub(input_buffer, 1, diff) .. _event.p1 .. string.sub(input_buffer, diff+1)
                local _, height = term.getSize()
                term.setCursorPos(2 + string.len(input_buffer) - input_offset + 1, height)
                term.setCursorBlink(true)
            end
        end
        coroutine.yield()
    end
end

function Program.Draw()
    term.setCursorPos(1, 1)
    printf('&6MTMOS V0.2.0A')
    --local screen = Program.container.screen
    while true do
        local width, height = term.getSize()
        if screen_buffer.has_changed then
            local cx, cy = term.getCursorPos()
            local display_offset = 0

            if #screen_buffer.content + screen_buffer.scroll_offset > height - 1 then
                display_offset = (#screen_buffer.content - (height - 1)) - screen_buffer.scroll_offset
            elseif #screen_buffer.content > height - 1 then
                display_offset = #screen_buffer.content - (height - 1)
            end

            for i=1,height-1 do
                term.setCursorPos(1, i)
                io.write(string.rep(' ', width))
                term.setCursorPos(1, i)
                printf(screen_buffer.content[i + display_offset], '\0')
            end
            screen_buffer.has_changed = false
            term.setCursorPos(cx, cy)
        end

        if input_buffer ~= previous_input_buffer then
            term.setCursorBlink(false)
            term.setCursorPos(1, height)
            io.write(string.rep(' ', width))
            term.setCursorPos(1, height)
            printf('&6$ &0', '\0')
            io.write(input_buffer)
            term.setCursorBlink(true)
            term.setCursorPos(3 + string.len(input_buffer) - input_offset, height)

            previous_input_buffer = input_buffer
        end

        --if
        coroutine.yield()
    end
end

return Program
