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
    VOLUME_NOW = {}

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
            VOLUME_NOW.device = s or "N/A"
        end)

        helpers.async({ shell, "-c",
            string.format("pactl get-%s-mute @DEFAULT_%s@", pipewire.devicetype,
                string.upper(pipewire.devicetype)) },
            function(s)
                VOLUME_NOW.muted = string.match(s, "Mute: (%S+)") or "N/A"
            end)

        helpers.async({ shell, "-c",
            string.format("pactl get-%s-volume @DEFAULT_%s@", pipewire.devicetype,
                string.upper(pipewire.devicetype)) },
            function(t)
                VOLUME_NOW.channel = {}
                for v in string.gmatch(t, ":.-(%d+)%%") do
                    VOLUME_NOW.channel[#VOLUME_NOW.channel + 1] = tonumber(v) or 0
                end

                VOLUME_NOW.left  = VOLUME_NOW.channel[1]
                VOLUME_NOW.right = VOLUME_NOW.channel[2]

                widget = pipewire.widget
                icon = pipewire.icon
                settings()
            end)
    end

    function pipewire.icon(volume)
        local icons = beautiful.pipewire_icons or {
            "󰖁", "󰕿", "󰖀", "󰕾"
        }

        local idx = volume and math.ceil(volume * (#icons - 1) / 100) + 1 or 1
        return (VOLUME_NOW.muted == "yes") and "󰝟" or icons[idx]
    end

    helpers.newtimer("pipewire", timeout, pipewire.update)

    return pipewire
end

return factory
