local function mkdir(dir)
    shell.run("mkdir "..dir)
end

local function wget(url, name)
    shell.run("wget "..url.." "..name)
end

mkdir("MTMOS")

-- highest level scripts
mkdir("MTMOS/core")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/boot.lua", "MTMOS/core/boot.lua")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/events.lua", "MTMOS/core/events.lua")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/programs.lua", "MTMOS/core/programs.lua")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/screen.lua", "MTMOS/core/screen.lua")

-- required modules
mkdir("MTMOS/core/modules")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/modules/json.lua", "MTMOS/core/modules/json.lua")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/modules/num_to_hex.lua", "MTMOS/core/modules/num_to_hex.lua")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/modules/structs.lua", "MTMOS/core/modules/structs.lua")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/modules/utils.lua", "MTMOS/core/modules/utils.lua")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/modules/uuid.lua", "MTMOS/core/modules/uuid.lua")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/core/modules/uuid4.lua", "MTMOS/core/modules/uuid4.lua")

-- install the shell
mkdir("MTMOS/applications")
wget("https://raw.githubusercontent.com/MaxTheMooshroom/MTMOS/redo/applications/shell.lua", "MTMOS/applications/shell.lua")
