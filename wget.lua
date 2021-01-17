local args = {...}

local request, err = http.get(args[1])
local response = request.readAll()

if not(fs.exists(args[2])) then
    local file = fs.open(args[2], 'w')
    file.write(response)
    file.close()
else
    print("File \"" .. args[2] .. " already exists!")
end
