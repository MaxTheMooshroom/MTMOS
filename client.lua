local modem_loc = {...}[1]

rednet.open(modem_loc)

-- comment

while true do
    rednet.broadcast(os.getComputerID())
    local master, message, protocol = rednet.receive(5)

    if not(message == nil) then break end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function split(input, sep)
    if set == nil then
        sep = "%s" --default sep to space
    end

    local t = {}

    for match in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, match)
    end

    return t
end

local terminal_redirect = deepcopy(term.current())
terminal_redirect.write = function(content)
    rednet.send(master, "message:"content)
end

term.redirect(terminal_redirect)

while true do
    local sender, command, protocol = rednet.receive()

    local args = split(command)
    local func = args[1]
    table.remove(args, 1)

    local val, err = pcall(loadstring(func.."()"), unpack(args))

    if not(err == nil) then
        print("message:"..val)
        rednet.send(master, "response:"..err)
    else
        rednet.send(master, "response:okay")
    end
end
