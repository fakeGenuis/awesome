local awful        = require("awful")
local wibox        = require("wibox")
local beautiful    = require("beautiful")
local shell        = require('awful.util').shell
local generate_key = require("helpers.generate_key")
local mywidgets    = require("helpers.mywidgets")
local images       = require("helpers.images")
local naughty      = require("naughty")
local helpers      = require('lain.helpers')

local command      = "maim -b 3 -u "

-- random string, see https://gist.github.com/haggen/2fd643ea9a261fea2094
local charset      = {}
do -- [0-9a-zA-Z]
    for c = 48, 57 do table.insert(charset, string.char(c)) end
    for c = 65, 90 do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

local function randomString(length)
    if not length or length <= 0 then return '' end
    math.randomseed(os.time())
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end

local actions    = {
    target = {
        {
            name = "select",
            argu = "-s "
        }, {
        name = "screen",
        -- space make no sense in shell script, but will be treated as true argu and
        -- sth. return argu
        -- set delay to avoid tools itself appears in screen-shot
        argu = "-d 0.5 "
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
        argu = " ",
        callback = function(exec_command)
            local image_name = string.format("%s_%s.png", os.date("%y-%m-%d"),
                randomString(8))
            local image_path = beautiful.screenshots_dir .. image_name
            local new_command = exec_command .. image_path

            helpers.async({ shell, "-c", new_command }, function(_)
                naughty.notify {
                    title = "Screenshot",
                    message = "saved to " .. image_path,
                    app_icon = "Diana-Circle"
                }
            end)
        end
    }, {
        name = "clipboard",
        icon_name = "clipboard",
        argu = " ",
        callback = function(exec_command)
            local image_path = "/tmp/" .. randomString(8) .. ".png"
            helpers.async({ shell, "-c", exec_command, "> " .. image_path }, function(_)
                -- nothing can do here, process will not terminated until something
                -- else send to clipboard.
                awful.spawn.with_shell(
                    "xclip -selection clipboard -t image/png " .. image_path)
                awful.spawn.with_shell("rm " .. image_path)
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

local existed    = {}
local key_map    = {}
local screenshot = {}

-- generate key in `actions`
-- add key box to layout widgets
for k, v in pairs(actions) do
    screenshot[k] = wibox.layout.fixed.horizontal()
    screenshot[k].spacing = beautiful.spacing
    for _, act in ipairs(v) do
        generate_key(act, existed, { modifiers = {} })
        key_map[act.key] = act

        screenshot[k]:add(images.image_desc_box(act))
    end
end

screenshot.popup = awful.popup {
    widget = {
        widget = wibox.container.margin,
        margins = beautiful.margin_spacing,
        {
            layout = wibox.layout.fixed.vertical,
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
