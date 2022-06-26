local lain      = require("lain")
local markup    = lain.util.markup
local beautiful = require("beautiful")

-- lower letter -> 1
-- upper letter -> 0
-- neither      -> nil
local function is_letter(string_byte)
    return (97 < string_byte and string_byte < 122) and 1 or
        ((65 < string_byte and string_byte < 90) and 0 or nil)
end

-- generate keys from a description
local function generate_key(key_description, exist_keys, args)
    args = args or {}
    local max_len = args.max_len or 100
    -- default modifiers is alt
    local modifiers = args.modifiers or { "Mod1" }
    -- wrap key string with a format
    local wrapper = args.wrapper or function(key)
        return markup.font("Bold", markup.fg
            .color(beautiful.fg_urgent,
                string.format("(%s)", key)))
    end
    local key

    -- https://stackoverflow.com/a/49222705
    local desc = { key_description:byte(1, math.min(#key_description, max_len)) }
    for i = 1, #desc do
        local c = desc[i]
        local letter_code = is_letter(c)

        if letter_code and not exist_keys[c] then
            exist_keys[c] = true

            if letter_code == 0 then
                modifiers[#modifiers + 1] = "Shift"
            end

            key = string.char(c)
            return {
                -- https://stackoverflow.com/a/24945624
                description = key_description:gsub("()" .. key,
                    { [i] = wrapper(key) }),
                modifiers = modifiers,
                key = key
            }
        end
    end

    for i = 97, 122 do
        if not exist_keys[i] then
            exist_keys[i] = true
            key = string.char(i)
            return {
                description = wrapper(key) .. key_description,
                modifiers = modifiers,
                key = key
            }
        end
    end

    modifiers[#modifiers + 1] = "Shift"

    for i = 65, 90 do
        if not exist_keys[i] then
            exist_keys[i] = true
            key = string.char(i)
            return {
                description = wrapper(key) .. key_description,
                modifiers = modifiers,
                key = key
            }
        end
    end

end

return generate_key
