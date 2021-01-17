local modem_loc = {...}[1]

rednet.open(modem_loc)

while true do
    io.write("$ ")
    local command = read()

    rednet.broadcast(command)
