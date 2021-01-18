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
        rednet.send(server, args[2], "ftp") -- send the desired filename to ftp server
        local _, file, protocol = rednet.receive() -- wait for ftp to respond indefinetely for file contents
        f = fs.open(args[2], 'w')
        f.write(file)
        f.close()
    end
elseif args[1] == "host" then
    rednet.host("ftp", "ftpserver")
    while true do
        local sender, message, protocol = rednet.receive(1) -- listen for connection request for 1 second
        if protocol == "ftp" then
            --rednet.send(sender, "ftp") -- respond with "I'm here!", so to speak
            --local sender2, file, protocol2 = rednet.receive(5) -- wait 5 seconds to receive filename
            f = fs.open(file, 'r')
            rednet.send(sender, f.readAll()) -- send back file contents
            f.close()
            print("Sent \""..file.."\" to computer "..sender) -- log the interaction
        end
    end
end
