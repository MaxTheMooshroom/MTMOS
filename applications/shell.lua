require("MTMOS/core/screen")

local Program = {}

Program.prefix = '&6$ '
Program.insert_prefix = '> '

Program.shell_objects = { {output=OSNAME..' V'..OSVERSION}, }
local shell_v_offset = 0
local shell_should_draw_objects = true

local input_buffer = ''
local shell_h_input_offset = 0
local shell_h_input_display_offset = 0
local shell_should_draw_input_buffer = true

--[[
    input: Array[string], output: Array[string]
    input is for use of this program only, used by run()
]]
local function shellObject(output, input)
    table.insert(Program.shell_objects, {input=input, output=output, from=Programs.findByThread(coroutine.running()).name})
end

--[[
    text: string
]]
local function shellWrite(text)
    local words = stringutils.split(text)
    local lines = {''}

    local width, height = term.getSize()
    for i=1,#words do
        local word = words[i]
        if stringutils.formattedLength(lines[#lines]) + stringutils.formattedLength(word) + 1 <= width then
            lines[#lines] = lines[#lines]..' '..word
        else
            table.insert(lines, word)
        end
    end
    shellObject(lines)
end

local function formatShellObjects()

end

local function run(input)
    
end

local function cprint(text, val, cy)
    local width = term.getCursorPos()
    text = text..": "..tostring(val)
    term.setCursorPos(1, cy)
    printf('&f'..string.rep(' ', width))
    term.setCursorPos(1, cy)
    printf(text, '\0')
end

function Program.Info()
    Program.container.name = 'mtmos-shell'
end

function Program.Main()
    Program.container.write = shellWrite
    Program.container.run = run
    coroutine.yield()
    term.setCursorBlink(true)
    while true do
        local _event = Program.container.eq:pop()
        if _event ~= nil then
            local width, height = term.getSize()
            -- Event Types
            if _event.type == 'char' then
                input_buffer = string.sub(input_buffer, 1, shell_h_input_offset) .. _event.p1 .. string.sub(input_buffer, shell_h_input_offset+1)
                shell_h_input_offset = shell_h_input_offset + 1
                if stringutils.formattedLength(input_buffer) + stringutils.formattedLength(Program.prefix) > width - 1 then
                    shell_h_input_display_offset = shell_h_input_display_offset + 1
                end
                shell_should_draw_input_buffer = true
            elseif _event.type == 'key' then
                if _event.p1 == keys.backspace then
                    if shell_h_input_offset ~= 0 then
                        input_buffer = string.sub(input_buffer, 1, shell_h_input_offset-1) .. string.sub(input_buffer, shell_h_input_offset+1)
                        shell_h_input_offset = shell_h_input_offset - 1

                        if stringutils.formattedLength(input_buffer) + stringutils.formattedLength(Program.prefix) >= width - 1 then
                            shell_h_input_display_offset = shell_h_input_display_offset - 1
                        end

                        if shell_h_input_offset < shell_h_input_display_offset then
                            shell_h_input_display_offset = shell_h_input_offset
                        end

                        if shell_h_input_offset > stringutils.formattedLength(input_buffer) then
                            shell_h_input_offset = shell_h_input_offset - 1
                        end
                    end
                    shell_should_draw_input_buffer = true
                elseif _event.p1 == keys.delete then
                    if shell_h_input_offset ~= 0 then
                        input_buffer = string.sub(input_buffer, 1, shell_h_input_offset) .. string.sub(input_buffer, shell_h_input_offset+2)
                        shell_should_draw_input_buffer = true
                    end
                elseif _event.p1 == keys.left then
                    if shell_h_input_offset ~= 0 then
                        shell_h_input_offset = shell_h_input_offset - 1
                        if shell_h_input_offset < shell_h_input_display_offset then
                            shell_h_input_display_offset = shell_h_input_offset
                        elseif shell_h_input_offset > stringutils.formattedLength(input_buffer) then
                            shell_h_input_offset = shell_h_input_offset - 1
                        end
                        shell_should_draw_input_buffer = true
                    end
                elseif _event.p1 == keys.right then
                    if shell_h_input_offset ~= stringutils.formattedLength(input_buffer) then
                        if stringutils.formattedLength(Program.prefix) - shell_h_input_display_offset + shell_h_input_offset + 1 == width then
                            shell_h_input_display_offset = shell_h_input_display_offset + 1
                        end
                        shell_h_input_offset = shell_h_input_offset + 1
                        shell_should_draw_input_buffer = true
                    end
                elseif _event.p1 == keys.up then
                elseif _event.p2 == keys.down then
                elseif _event.p1 == keys.enter or _event.p1 == keys.numPadEnter then
                    parse()
                end
            end
        end

        coroutine.yield()
    end
end

function Program.Draw()
    while true do
        local width, height = term.getSize()
        local cx_new = stringutils.formattedLength(Program.prefix) - shell_h_input_display_offset + shell_h_input_offset + 1
        -- cprint("&1cx_new", cx_new, 2)
        -- cprint("&2shell_h_input_offset", shell_h_input_offset, 3)
        -- cprint("&3shell_h_input_display_offset", shell_h_input_display_offset, 4)
        -- cprint("&4width", width, 6)
        -- cprint("&5#input_buffer + #prefix", stringutils.formattedLength(input_buffer) + stringutils.formattedLength(Program.prefix), 7)
        -- cprint("&6input cursor x position", stringutils.formattedLength(Program.prefix) - shell_h_input_display_offset + shell_h_input_offset + 1, 8)
        term.setCursorPos(cx_new, height)

        if shell_should_draw_objects then

        end

        if shell_should_draw_input_buffer then
            local input_display_string
            if stringutils.formattedLength(Program.prefix) + stringutils.formattedLength(input_buffer) < width then
                input_display_string = input_buffer
            else
                input_display_string = string.sub(input_buffer, shell_h_input_display_offset + 1, shell_h_input_display_offset + width - stringutils.formattedLength(Program.prefix))
            end
            term.setCursorPos(1, 1)
            io.write(string.rep(' ', width))
            term.setCursorPos(1, 1)
            printf(input_display_string)
            term.setCursorPos(1, height)
            io.write(string.rep(' ', width))
            term.setCursorPos(1, height)
            printf(Program.prefix, '\0')
            io.write(input_display_string)
            shell_should_draw_input_buffer = false
        end

        coroutine.yield()
    end
end

return Program
