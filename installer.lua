local function wget(url, name)
    shell.run("wget "..url.." "..name)
end
