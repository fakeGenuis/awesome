--[[

     Licensed under GNU General Public License v2
      * (c) 2016, Luca CPZ

--]]

local helpers = require("lain.helpers")
local shell   = require("awful.util").shell
local wibox   = require("wibox")
local string  = string
local type    = type

-- PulseAudio volume
-- lain.widget.pulse

local function factory(args)
    args = args or {}

    local pulse    = { widget = args.widget or wibox.widget.textbox(), device = "N/A" }
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    pulse.devicetype = args.devicetype or "sinks"
    pulse.cmd = args.cmd or "pactl list " .. pulse.devicetype

    function pulse.update()
        helpers.async({ shell, "-c", type(pulse.cmd) == "string" and pulse.cmd or pulse.cmd() },
            function(s)
                local start_pos = string.find(s, "State: RUNNING") or 1
                local end_pos = string.find(s, "State: ", start_pos + 1) or -1

                volume_now = {
                    muted  = string.match(s, "Mute: (%S+)", start_pos) or "N/A",
                    device = string.match(s, "device.description = \"(%S+)\"", start_pos) or "N/A"
                }

                local ch = 1
                volume_now.channel = {}
                for v in string.gmatch(string.sub(s, start_pos, end_pos), ":.-(%d+)%%") do
                    volume_now.channel[ch] = v
                    ch = ch + 1
                end

                volume_now.left  = volume_now.channel[1] or "N/A"
                volume_now.right = volume_now.channel[2] or "N/A"

                widget = pulse.widget
                settings()
            end)
    end

    helpers.newtimer("pulse", timeout, pulse.update)

    return pulse
end

return factory
