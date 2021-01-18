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

local delim = ':'
local args = {...}
local modem_loc = args[3]

rednet.open(modem_loc)

if args[1] == "fetch" then
    if fs.exists(args[2]) then
        print("File already exists!")
        exit()
    end
    local server = rednet.lookup("ftp", "ftpserver") -- DNS lookup for the ftpserver
    if server == nil then
        print("ftp server not found")
    else
        rednet.send(server, "fetch"..delim..args[2], "ftp") -- send the desired filename to ftp server
        local _, file, protocol = rednet.receive() -- wait for ftp to respond indefinetely for file contents
        local f = fs.open(args[2], 'w')
        f.write(file)
        f.close()
    end
elseif args[1] == "send" then
    local server = rednet.lookup("ftp", "ftpserver") -- DNS lookup for the ftpserver
    if server == nil then
        print("ftp server not found")
        exit()
    else
        --local _, file, protocol = rednet.receive() -- wait for ftp to respond indefinetely for file contents
        local f = fs.open(args[2], 'r')
        print("Sending "..args[2].." to ftp server at address "..tostring(sender))
        rednet.send(server, "send"..delim..args[2]..delim..f.readAll(), "ftp") -- send the desired filename to ftp server
        f.close()
        print("Waiting for response...")
        local s, m, p = rednet.receive()
        if m ~= "okay" then
            print("[Error]: "..m)
            exit()
        else
            print('Success')
        end
    end
elseif args[1] == "host" then
    rednet.host("ftp", "ftpserver")
    while true do
        local sender, message, protocol = rednet.receive(1) -- listen for connection request for 1 second
        if protocol == "ftp" then
            --rednet.send(sender, "ftp") -- respond with "I'm here!", so to speak
            --local sender2, file, protocol2 = rednet.receive(5) -- wait 5 seconds to receive filename
            local arguments = split(message, delim)

            print("Received \""..arguments[1].."\" request from address "..tostring(sender))

            if arguments[1] == "fetch" then
                local f = fs.open(arguments[2], 'r')
                rednet.send(tostring(sender), f.readAll()) -- send back file contents
                f.close()
                print("Sent \""..file.."\" to computer "..sender) -- log the interaction

            elseif arguments[1] == "send" then
                if fs.exists(arguments[2]) then
                    print(sender.." tried to send \""..arguments[2].."\", but it already exists locally")
                    rednet.send(sender, "File already exists")
                else
                    print("Saving data to file \""..arguments[2].."\"")
                    local f = fs.open(arguments[2], 'w')
                    f.write(arguments[3])
                    f.close()
                    rednet.send(sender, "okay")
                    print("device \""..sender.."\" uploaded "..arguments[2])
                end
            end
        end
    end
end
