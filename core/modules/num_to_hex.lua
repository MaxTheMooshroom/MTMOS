-- Original was written for pico-8, had to migrate to raw lua 5.1
-- credit: https://www.lexaloffle.com/bbs/?tid=30910
function _G.to_hex(number, num_digits)
    if type(number) ~= "number" then error("Must be a number") end

    local base = 16
    local result = {}
    local resultstr = ""

    local digits = "0123456789abcdef"
    local quotient = math.floor(number / base)
    local remainder = number % base

    table.insert(result, string.sub(digits, remainder + 1, remainder + 1))

    while (quotient > 0) do
        local old = quotient
        quotient = quotient / base
        quotient = math.floor(quotient)
        remainder = old % base

        table.insert(result, string.sub(digits, remainder + 1, remainder + 1))
    end

    for i = #result, 1, -1 do
        resultstr = resultstr..result[i]
    end

    if num_digits ~= nil then
        local diff = num_digits - string.len(resultstr)
        resultstr = string.rep('0', diff)..resultstr
    end

    return resultstr
end
