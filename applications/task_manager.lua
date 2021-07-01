local Program = {}

function Program.Info(_P)
    Program.container.name = "dummy"
end

function Program.Main(_P)
    while true do
        coroutine.yield()
    end
end

-- function Program.Draw(_P)
--
-- end

return Program
