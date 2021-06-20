require("modules/utils")

_G.Screen = {}

function Screen.new(parent, nX, nY, nWidth, nHeight)
    local new_screen = {}
    new_screen.contents = {}
    new_screen.scroll_offset = 0
    local parent_width, parent_height = parent.getSize()
    new_screen.window = window.create(parent, 1, 1, parent_width, parent_height, false)

    function new_screen.write(content)
        if type(content) ~= "string" and type(content) ~= "number" then
            content = "&eAttempted to print an invalid type"
        elseif type(content) == "number" then
            content = to_string(content)
        end

        local words = stringutils.split(content)
        local width = term.getSize()
        local lines = {words[1]}
        local line_index = 1

        for i=2, #words do
            local word = words[i]
            if string.len(lines[line_index]) + string.len(word) + 1 < width then
                lines[line_index] = lines[line_index]..' '..word
            else
                line_index = line_index + 1
                lines[line_index] = word
            end
        end

        for i=1, #lines do
            new_screen.contents[#new_screen.contents + 1] = lines[i]
        end
    end

    function new_screen.display()
        local display_offset = 0
        local _, height = term.getSize()
        if #new_screen.contents + scroll_offset > height then
            display_offset = scroll_offset
        elseif #new_screen.contents > height then
            display_offset = #new_screen.contents - height
        end

        local _to_restore = term.current()
        term.redirect(new_screen.window)
        for i=1,#height do
            term.setCursorPos(1, i)
            printf(new_screen.contents[i + display_offset])
        end
        term.redirect(_to_restore)
    end

    return new_screen
end
