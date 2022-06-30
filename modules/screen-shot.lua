local awful        = require("awful")
local wibox        = require("wibox")
local beautiful    = require("beautiful")
local shell        = require('awful.util').shell
local generate_key = require("helpers.generate_key")
local mywidgets    = require("helpers.mywidgets")
local images       = require("helpers.images")
local naughty      = require("naughty")
local helpers      = require('lain.helpers')

local command = "maim -b 3 -u "

local actions = {
    target = {
        {
            name = "select",
            argu = "-s "
        }, {
            name = "screen",
            -- space make no sense in shell script,
            -- but will be treated as true
            -- argu and sth. return argu
            argu = " "
        }
    },
    output = {
        {
            name = "attach",
            icon_name = "pin",
            argu = " | feh --no-screen-clip -"
        }, {
            name = "file",
            icon_name = "gallery",
            callback = function(exec_command)
                helpers.async({ "bash", "-c", "echo $(date +%F_%T).png" }, function(s)
                    local image_path = beautiful.screenshot_dir .. s
                    local exec_command = exec_command .. image_path

                    helpers.async({ shell, "-c", exec_command }, function(_)
                        naughty.notify {
                            title = "Screenshot",
                            message = "saved to " .. image_path,
                            app_icon = "Diana-Circle"
                        }
                    end)
                end)
            end
        }, {
            name = "clipboard",
            icon_name = "clipboard",
            argu = " | xclip -selection clipboard -t image/png",
            callback = function(exec_command)
                helpers.async({ shell, "-c", exec_command }, function(_)
                    naughty.notify {
                        title = "Screenshot",
                        message = "copied to clipboard",
                        app_icon = "Diana-Circle"
                    }
                end)
            end
        }
    }
}

local existed = {}
local key_map = {}
local screenshot = {}

-- generate key in `actions`
-- add key box to layout widgets
for k, v in pairs(actions) do
    screenshot[k] = wibox.layout.fixed.horizontal()
    for _, act in ipairs(v) do
        generate_key(act, existed, { modifiers = {} })
        key_map[act.key] = act

        screenshot[k]:add(images.image_desc_box(act))
    end
end

screenshot.popup = awful.popup {
    widget = {
        widget = wibox.container.margin,
        top = beautiful.margin_spacing,
        bottom = beautiful.margin_spacing,
        { layout = wibox.layout.fixed.vertical,
            spacing = beautiful.spacing,
            mywidgets.block(mywidgets.textbox { markup = "Screen-shot Tool" }),
            screenshot.target,
            screenshot.output,
        },
    },
    placement = awful.placement.centered,
    ontop = true,
    visible = false,
    type = "utility",
    -- screen = s,
    shape = mywidgets.shape
}

screenshot.stop_keys = { "Escape" }
for _, act in ipairs(actions.output) do
    table.insert(screenshot.stop_keys, act.key)
end

screenshot.grabber = awful.keygrabber {
    timeout = beautiful.timeout,
    stop_event = 'press',
    -- stop_key triggered before keybindings work
    -- so one cannot put keys in keybindings to stop_keys
    stop_key = screenshot.stop_keys,
    -- timeout_callback = function() end,
    -- stop_callback still called after timeout
    stop_callback = function(_, stop_key, _, sequence)
        awesome.emit_signal('module::screenshot:hide')

        -- in case timout
        if stop_key == nil or stop_key == "Escape" then return end

        local target = sequence:sub(-1, -1)

        local exec_command = string.format("%s%s%s",
            command,
            key_map[target] and key_map[target].argu or actions.target[1].argu,
            key_map[stop_key].argu)

        if key_map[stop_key].callback then
            key_map[stop_key].callback(exec_command)
        else
            awful.spawn({ shell, "-c", exec_command })
        end
    end
}

awesome.connect_signal('module::screenshot:show', function()
    screenshot.popup.screen = awful.screen.focused()
    screenshot.popup.visible = true
    screenshot.grabber:start()
end)

awesome.connect_signal('module::screenshot:hide', function()
    screenshot.popup.visible = false
end)
