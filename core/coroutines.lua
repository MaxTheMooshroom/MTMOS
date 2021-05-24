local native_coroutines = {}
_G.native_coroutines = native_coroutines

local shell_input_buffer = ""
local shell_cursor_position = 3 -- unused; will be used with left/right arrow keys
function _shell_char_routine(p1, p2, p3, p4, p5) -- char event
    term.setCursorBlink(true)
    term.setCursorPos(1, 19)
    io.write('$ ')
    while true do
        term.setCursorPos(3 + #shell_input_buffer, 19)
        io.write(p1)
        shell_input_buffer = shell_input_buffer..p1
        p1, p2, p3, p4, p5 = coroutine.yield()
    end
end
_G.shell_char_routine = coroutine.create(_shell_char_routine)
CoroutineManager.addListener(shell_char_routine, "char")

function shell_key_routine(p1, p2, p3, p4, p5) -- key event
    while true do
        if p1 == keys.enter then
            print()
            local args = stringutils.split(shell_input_buffer)
            local command = args[1]

            table.remove(args, 1)

            if command == "exit" then coroutine.yield("exit") end
            local func, err = findfunction('command_list.'..command)

            if err ~= nil then
                print("Could not find command \""..command.."\"")
                print(err)
            else
                if #args == 0 then
                    func()
                else
                    func(stringutils.join(args))
                end
            end
            shell_input_buffer = ''
            term.setCursorPos(1, 19)
            io.write('$ ')
        elseif p1 == keys.backspace then
            local x, y = term.getCursorPos()
            if x > 3 then
                shell_input_buffer = shell_input_buffer:sub(1, -2)
                term.setCursorPos(x-1, y)
                io.write(' ')
                term.setCursorPos(x-1, y)
            end
        end
        p1, p2, p3, p4, p5 = coroutine.yield()
    end
end
CoroutineManager.addListener(coroutine.create(shell_key_routine), "key")