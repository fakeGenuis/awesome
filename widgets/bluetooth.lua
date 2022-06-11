--[[

     Licensed under GNU General Public License v2
      * (c) 2016, Luca CPZ

--]]

local helpers   = require("lain.helpers")
local shell     = require("awful.util").shell
local wibox     = require("wibox")
local beautiful = require("beautiful")
local string    = string

-- bluetooth headset battery
-- lain.widget.bluetooth

local function factory(args)
    args = args or {}

    local bluetooth = { widget = args.widget or wibox.widget.textbox(), device = "N/A" }
    local timeout   = args.timeout or 5
    local settings  = args.settings or function() end

    bluetooth.devicetype = args.devicetype or "headset"
    battery_now = {}

    function bluetooth.update()
        helpers.async({ shell, "-c",
            string.format("upower -e | grep %s | head -1", bluetooth.devicetype) }, function(s)
            battery_now.device_path = s or "N/A"
        end)

        helpers.async({ shell, "-c",
            string.format("upower -i %s", battery_now.device_path) }, function(s)
            battery_now.model = string.match(s, "model: +(%S+)") or "N/A"
            battery_now.charged = string.match(s, "power supply: +(%S+)") or "N/A"
            battery_now.battery = tonumber(string.match(s, "percentage: +(%d+)%%")) or 0
            battery_now.icon = bluetooth.icon(battery_now.battery) or "N/A"

            widget = bluetooth.widget
            settings()
        end)
    end

    function bluetooth.icon(battery)
        local icons = beautiful.bluetooth_battery_icons or
            {"󱃍", "󰤾", "󰤿", "󰥀", "󰥁", "󰥂", "󰥃", "󰥄", "󰥅", "󰥆", "󰥈" }

        local idx = math.ceil(battery * (#icons - 1) / 100) + 1
        return (battery_now.model == "N/A") and "" or icons[idx]
    end

    helpers.newtimer("bluetooth", timeout, bluetooth.update)

    return bluetooth
end

return factory
