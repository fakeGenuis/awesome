local helpers   = require("lain.helpers")
local shell     = require("awful.util").shell
local wibox     = require("wibox")
local beautiful = require("beautiful")
local string    = string

-- pipewire volume
-- lain.widget.pipewire

local function factory(args)
    args = args or {}

    local pipewire = { widget = args.widget or wibox.widget.textbox() }
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    pipewire.devicetype = args.devicetype or "sink"
    volume_now = {}

    -- pipewire.widget:buttons(gears.table.join(
    --     awful.button({}, 4, function() -- scroll up
    --         awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +3%", false)
    --     end),
    --     awful.button({}, 5, function() -- scroll down
    --         awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -3%", false)
    --     end))
    -- )

    function pipewire.update()
        helpers.async({ shell, "-c",
            string.format("pactl get-default-%s", pipewire.devicetype) }, function(s)
            volume_now.device = s or "N/A"

            helpers.async({ shell, "-c",
                string.format("pactl list %ss", pipewire.devicetype) }, function(ss)
                local idx = 1
                local sub_ss

                while idx do
                    local next_pos = ss:find("Sink #%d+", idx + 1)
                    sub_ss = ss:sub(idx, next_pos or -1)
                    idx = next_pos
                    if sub_ss:find(volume_now.device) then
                        break
                    end
                end

                volume_now.muted = string.match(sub_ss, "Mute: (%S+)") or "N/A"

                volume_now.channel = {}
                for v in string.gmatch(sub_ss, ":.-(%d+)%%") do
                    volume_now.channel[#volume_now.channel + 1] = tonumber(v) or 0
                end

                volume_now.left  = volume_now.channel[1]
                volume_now.right = volume_now.channel[2]

                widget = pipewire.widget
                icon = pipewire.icon
                settings()
            end)
        end)

        -- helpers.async({ shell, "-c",
        --     string.format("pactl get-%s-mute @DEFAULT_%s@", pipewire.devicetype, string.upper(pipewire.devicetype)) },
        --     function(s)
        --         volume_now.muted = string.match(s, "Mute: (%S+)") or "N/A"
        --     end)

        -- helpers.async({ shell, "-c",
        --     string.format("pactl get-%s-volume @DEFAULT_%s@", pipewire.devicetype, string.upper(pipewire.devicetype)) },
        --     function(t)
        --         volume_now.channel = {}
        --         for v in string.gmatch(t, ":.-(%d+)%%") do
        --             volume_now.channel[#volume_now.channel + 1] = tonumber(v)
        --         end

        --         volume_now.left  = volume_now.channel[1]
        --         volume_now.right = volume_now.channel[2]

        --         widget = pipewire.widget
        --         icon = pipewire.icon
        --         settings()
        --     end)
    end

    function pipewire.icon(volume)
        local icons = beautiful.pipewire_icons or {
            "󰖁", "󰕿", "󰖀", "󰕾" }

        local idx = math.ceil(volume * (#icons - 1) / 100) + 1
        return (volume_now.muted == "yes") and "󰝟" or icons[idx]
    end

    helpers.newtimer("pipewire", timeout, pipewire.update)

    return pipewire
end

return factory
