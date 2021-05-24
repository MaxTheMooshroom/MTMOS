local command_list = {}
local helper = {}
_G.command_list = command_list
_G.helper = helper


-- Found below are shell commands that users may use in MTMOS by default.
-- Additional packages may add more commands, see their documentation for details.

-- help with printf colours
function command_list.colors()
    printf("Here are the colors:\n")
    printf("&00&11&22&33&44&55&66&77&88&99&aa&bb&cc&dd&ee&ff")
end
helper[commands.colors] = [[Prints a list of colour codes in their corresponding colour

Usage:
&2$ colors
]]




function command_list.shell(str)
    shell.run(str)
end
helper[commands.shell] = [[Runs a command using CraftOS.

Usage:
&2$ shell <command>
]]




function command_list.lua(str)
    printf("&eWARNING! VERY WIP! CURRENTLY BROKEN")
    if str == nil then
        global_states["function_count"] = global_states["function_count"] + 1
        shell.run('lua')
    else
        loadstring(str)()
    end
end
helper[commands.lua] = [[opens the lua interpreter (&eWIP&0)

Usage:
&2$ lua
]]




function command_list.clear()
    shell.run("clear")
    printf("&2MTMOS V0.1.0")
end
helper[commands.clear] = [[Clears the screen

Usage:
&2$ clear
]]




function command_list.help(command)
    if command == nil then
        local count = 0
        for i in pairs(commands) do count = count + 1 end
        printf("&1Commands found: "..tostring(count))
        for k in tableutils.sortedKeys(commands) do
            print(k)
        end
        print()
    else
        command = "commands."..command
        local func, err = findfunction(command)
        if err == nil then
            printf(helper[func])
        else
            print("command \""..command.."\" not found")
        end
    end
end
helper[commands.help] = [[Provides help with registered commands

Usage:
&2$ help
Lists available commands

&2$ help <command>
Provides help with a specific command
]]
