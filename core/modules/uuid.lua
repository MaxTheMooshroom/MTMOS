require("modules/uuid4")
require("modules/utils")
require("modules/num_to_hex")

-- UUIDv4 - uses string version and is parsed into 4 32-bit numbers
-- TODO Integrate the 2 functions such that a string is not generated
function _G.UUID(value)
    local new_uuid = {}

    if value == nil then value = UUIDv4() end
    new_uuid.values = {}

    if value == 0 then -- generate nil UUID
        new_uuid.values[1] = 0
        new_uuid.values[2] = 0
        new_uuid.values[3] = 0
        new_uuid.values[4] = 0
    elseif type(value) == 'string' then
        value = string.gsub(value, '-', '')
        new_uuid.values[1] = tonumber(string.sub(value, 1, 8), 16)
        new_uuid.values[2] = tonumber(string.sub(value, 9, 16), 16)
        new_uuid.values[3] = tonumber(string.sub(value, 17, 24), 16)
        new_uuid.values[4] = tonumber(string.sub(value, 25, 32), 16)
    end

    function new_uuid.match(other_uuid)
        return (new_uuid.values[1] == other_uuid.values[1]) and (new_uuid.values[2] == other_uuid.values[2]) and (new_uuid.values[3] == other_uuid.values[3]) and (new_uuid.values[4] == other_uuid.values[4])
    end

    function new_uuid.to_string(self)
        local uuid_str = to_hex(self.values[1], 8)..to_hex(self.values[2], 8)..to_hex(self.values[3], 8)..to_hex(self.values[4], 8)
        uuid_str = stringutils.insert(uuid_str, '-', 20)
        uuid_str = stringutils.insert(uuid_str, '-', 16)
        uuid_str = stringutils.insert(uuid_str, '-', 12)
        uuid_str = stringutils.insert(uuid_str, '-', 8)
        return uuid_str
    end

    return new_uuid
end
