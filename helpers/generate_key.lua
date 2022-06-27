local beautiful = require("beautiful")
local lain      = require("lain")
local markup    = lain.util.markup
local math      = math
local string    = string

local function is_letter(string_byte)
    return (97 < string_byte and string_byte < 122) or
        (65 < string_byte and string_byte < 90)
end

--- Generate keys from an action
-- a method that update action's properties
--
-- action(table)  : action table with name, command keys
-- existed(table): track existed key
local function generate_key(action, existed, args)
    args = args or {}
    -- generate key from max_len of action.name
    local max_len = args.max_len or 10
    -- default modifiers is alt
    action.modifiers = action.modifiers or args.modifiers or { "Mod1" }
    -- wrap key string with a format
    local wrapper = args.wrapper or function(key)
        return markup.font("Bold", markup.fg.color(beautiful.fg_urgent,
            string.format("(%s)", key)))
    end
    local key = nil

    local new_existed = function(byte)
        existed[byte] = true
        key = string.char(byte)
        action.key = key
    end

    -- https://stackoverflow.com/a/49222705
    local desc = { string.byte(action.name, 1, math.min(#action.name, max_len)) }
    for i = 1, #desc do
        local byte = desc[i]
        -- https://stackoverflow.com/a/12929685
        if existed[byte] then goto continue end

        if is_letter(byte) then
            new_existed(byte)

            if 65 < byte and byte < 90 then
                action.modifiers[#action.modifiers + 1] = "Shift"
            end
            action.name = string.gsub(action.name, "()" .. key, { [i] = wrapper(key) })
            return
        end
        ::continue::
    end

    for byte = 97, 122 do
        if not existed[byte] then
            new_existed(byte)
            action.name = wrapper(key) .. action.name
            return
        end
    end

    action.modifiers[#action.modifiers + 1] = "Shift"

    for byte = 65, 90 do
        if not existed[byte] then
            new_existed(byte)
            action.name = wrapper(key) .. action.name
            return
        end
    end

end

return generate_key
