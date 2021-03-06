_G.stringutils = {}

function stringutils.split(input, sep)
    if sep == nil then
        sep = "%s"                                                              --default sep to space
    end

    local t = {}

    for match in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, match)
    end

    return t
end

function stringutils.join(data, sep)
    if sep == nil then
        sep = ' '
    end
    if #data == 0 then return "" end
    if #data == 1 then return data[1] end
    local t = data[1]
    for i=2,#data do
        t = t..sep..data[i]
    end
    return t
end

function stringutils.insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

function stringutils.popLeft(str, i)
    if i == nil then i = 1 end
    return string.sub(str, 1, i), string.sub(str, i + 1, -1)
end

-- breaks a string up by spaces or quotes.
-- credit: https://stackoverflow.com/questions/28664139/lua-split-string-into-words-unless-quoted
-- modified by MtM
function stringutils.parameterize(arguments)
    local result = {}
    local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
    for str in string.gmatch(arguments, "%S+") do
      local squoted = string.match(str, spat)
      local equoted = string.match(str, epat)
      local escaped = string.match(str, [=[(\*)['"]$]=])
      if squoted and not quoted and not equoted then
        buf, quoted = str, squoted
      elseif buf and equoted == quoted and #escaped % 2 == 0 then
        str, buf, quoted = buf .. ' ' .. str, nil, nil
      elseif buf then
        buf = buf .. ' ' .. str
      end
      if not buf then
          local temp = string.gsub(str, spat, "")
          result[#result + 1] = string.gsub(temp, epat, "")
      end
    end
    if buf then
        return -1
    else
        return result
    end
end


_G.tableutils = {}

function tableutils.getKeys(t)
    local t2 = {}
    local i = 0
    for k, v in pairs(t) do
        i = i + 1
        t2[i] = k
    end
    return t2
end

function tableutils.containsKey(t, key)
    local val = false
    for k, v in pairs(t) do
        if k == key then
            val = true
        end
    end
    return val
end

function tableutils.containsValue(t, key)
    local val = false
    for k, v in pairs(t) do
        if v == key then
            val = true
        end
    end
    return val
end

function tableutils.slice(array, start, _end)
    if _end == nil then
        _end = #array
    end
    results = {}
    local diff = _end - start
    for i=0,diff do
        results[i] = array[i + start]
    end
    return results
end

function tableutils.sortedKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)

    local i = 0                                                                 -- iterator variable

    local iter = function ()                                                    -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i]
        end
    end
    return iter
end

function tableutils.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[tableutils.deepcopy(orig_key)] = tableutils.deepcopy(orig_value)
        end
        setmetatable(copy, tableutils.deepcopy(getmetatable(orig)))
    else                                                                        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function tableutils.to_string(t, depth)
    if depth == nil then depth = 1 end
    local buffer = ''

    buffer = buffer..string.rep('  ', depth-1)..'{\n'
    for k,v in pairs(t) do
        local _type = type(v)
        if _type == 'table' then
            buffer = buffer..string.rep('  ', depth)..'['..k..'] =\n'
            buffer = buffer..tableutils.to_string(v, depth+1)..',\n'
        elseif _type == 'function' then
            buffer = buffer..string.rep('  ', depth)..'['..k..'] = function,\n'
        elseif _type == 'thread' then
            buffer = buffer..string.rep('  ', depth)..'['..k..'] = thread,\n'
        elseif _type == 'boolean' then
            local string_rep
            if v == true then string_rep = 'true,\n' else string_rep = 'false,\n' end
            buffer = buffer..string.rep('  ', depth)..'['..k..'] = '..string_rep
        elseif _type == 'string' then
            buffer = buffer..string.rep('  ', depth)..'['..k..'] = "'..v..'",\n'
        else
            buffer = buffer..string.rep('  ', depth)..'['..k..'] = '..v..',\n'
        end
    end
    buffer = buffer..string.rep('  ', depth-1)..'}'

    return buffer
end

function tableutils.dump(t, where)
    local file = fs.open(where, 'w')
    file.write(tableutils.to_string(t))
    file.close()
end

-- credit: http://www.computercraft.info/forums2/index.php?/topic/11771-print-coloured-text-easily/
-- modified by MTM
function _G.printf(text, _end)
    if text == '' or text == nil then return end
    local s = "%f&0"..text.."%f&0"

    local fields = {}
    local lastcolor, lastpos = "0", 1
    for pos, clr in string.gmatch(s, "()[&%%](%x)") do
        table.insert(fields, {s:sub(lastpos + 2, pos - 1), lastcolor, s:sub(lastpos, lastpos)=='&'})
        lastcolor, lastpos = clr, pos
    end

    for i=1, #fields do
        local _color = 2 ^ (tonumber(fields[i][2], 16))
        if fields[i][3] == true then
            term.setTextColour(_color)
        else
            term.setBackgroundColor(_color)
        end
        io.write(fields[i][1])
    end
    if _end == nil then
        _end = '\n'
    elseif _end == '\0' then
        _end = nil
    end
    if _end ~= nil then io.write(_end) end
    term.setTextColour(colors.white)
    term.setBackgroundColor(colors.black)
end

function stringutils.formattedLength(text)
    if text == '' or text == nil then return 0 end
    local s = text..'&0'
    local fields = {}
    local lastcolor, lastpos = "0", -1
    for pos, clr in string.gmatch(s, "()[&%%](%x)") do
        table.insert(fields, s:sub(lastpos + 2, pos - 1))
        lastcolor, lastpos = clr, pos
    end

    local formatted_string = ''
    for i=1, #fields do
        formatted_string = formatted_string..fields[i]
    end

    return string.len(formatted_string)
end


-- function for finding a function given its name as a string
-- credit: https://stackoverflow.com/questions/1791234/lua-call-function-from-a-string-with-function-name
function _G.findfunction(x, table)
  assert(type(x) == "string")
  local f = _G
  if table ~= nil then
      f = table
  end
  for v in x:gmatch("[^%.]+") do
    if type(f) ~= "table" then
       return nil, "looking for '"..v.."' expected table, not "..type(f)
    end
    f=f[v]
  end
  if type(f) == "function" then
    return f, nil
  else
    return nil, "expected function, not "..type(f)
  end
end

function _G.http_get(url)
    local current_prog = Programs.findByThread(coroutine.running())
    local headers = {
        url = url,
        uuid = current_prog.uuid.to_string(current_prog.uuid)
    }
    http.request("https://fe6db7c415c2.ngrok.io/get", nil, headers)

    Programs.suspend(current_prog)
    coroutine.yield()
    local found = false
    local response
    for i=1, current_prog.eq:size() do
        local __event = current_prog.eq:pop()
        if __event.type ~= "http_success" and __event.type ~= "http_failure" then
            current_prog.eq:push(__event)
        elseif found == false then
            local req_tab = __event.p2
            local req_uuid = UUID(req_tab['Uuid'])
            if req_uuid.match(current_prog.uuid) then
                response = __event
            end
        end
    end
    return response
end
