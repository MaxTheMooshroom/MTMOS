local Program = {}

local screen_buffer = {}
screen_buffer.cursor_pos = {x=1, y=1}
screen_buffer.offsets = {x=0, y=0}
screen_buffer.content = {}

function Program.Info()
    Program.container.name = 'mtmos-editor'
end

function Program.Main()
    coroutine.yield()

    while true do
        _event = Program.container.eq:pop()
        if _event ~= nil then
            if _event.type == 'char' then
            elseif _event.type == 'key' then
            elseif _event.type == 'key_up' then
            elseif _event.type == 'paste' then
            end
        end
        coroutine.yield()
    end
end

function Program.Draw()
    while true do
        coroutine.yield()
    end
end

return Program
