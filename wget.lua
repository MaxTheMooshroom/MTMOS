local args = {...}

local request, err = http.get(args[1])
local response = request.readAll()

local file = fs.open(args[2], 'w')
file.write(response)
file.close()
