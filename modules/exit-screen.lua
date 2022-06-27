local awful        = require("awful")
local beautiful    = require("beautiful")
local dpi          = beautiful.xresources.apply_dpi
local generate_key = require("helpers.generate_key")
local images       = require("helpers.images")
local wibox        = require("wibox")


-- all info in exit_screen
local actions = { -- index table to preserve order
    {
        name      = "reload",
        icon_name = "reload",
        command   = awesome.restart
    },
    {
        name      = "suspend",
        icon_name = "suspend",
        command   = "systemctl suspend"
    },
    {
        name      = "reboot",
        icon_name = "reboot",
        command   = "systemctl reboot"
    },
    {
        name      = "lock",
        icon_name = "lock-screen",
        command   = function(self)
            -- stop key grabber first for betterlockscreen (i3lock) to work
            -- otherwise: `i3lock: Cannot grab pointer/keyboard`
            self:stop()
            awful.spawn("betterlockscreen -l")
        end,
    },
    {
        name      = "logout",
        icon_name = "log-out",
        command   = awesome.quit
    },
    {
        name      = "shutdown",
        icon_name = "shut-down",
        command   = "systemctl poweroff"
    }
}

local cancel_action = {
    name      = "cancel",
    icon_name = "cancel",
    modifiers = {},
    keys      = { "q", "c", "Escape" }
}

local profile_action = {
    name      = os.getenv("USER"),
    icon_name = os.getenv("HOME") .. "/.face"
}


local existed = {}
for _, i in pairs(cancel_action.keys) do
    existed[string.byte(i)] = true
end

-- update actions by add act.key and update act.name
for _, act in ipairs(actions) do
    generate_key(act, existed, { modifiers = {} })
end

local create_exit_screen = function(s)
    s.exit_screen = wibox {
        bg        = beautiful.transparen,
        fg        = beautiful.fg_focus,
        ontop     = true,
        opacity   = 0.75,
        placement = awful.placement.center,
        type      = 'splash',
        visible   = false,
        widget    = {},
        height    = s.geometry.height,
        width     = s.geometry.width,
        x         = s.geometry.x,
        y         = s.geometry.y
    }

    local action_boxs = {}
    for _, act in ipairs(actions) do
        table.insert(action_boxs,
            images.image_desc_box(act, { prefix = "system-" }))
    end
    action_boxs.layout = wibox.layout.fixed.horizontal
    action_boxs.spacing = dpi(96)

    local profile_box = images.image_desc_box(profile_action, { image_size = dpi(96) })
    local cancel_box = images.image_desc_box(cancel_action, { prefix = "system-" })

    s.exit_screen:setup {
        {
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(64),
            profile_box,
            action_boxs,
            cancel_box
        }, widget = wibox.container.place }
end

local exit_keys = {}

for _, act in ipairs(actions) do
    if type(act.command) == "function" then
        act.on_press = act.command
    elseif type(act.command) == "string" then
        act.on_press = function() awful.spawn(act.command) end
    end
    table.insert(exit_keys, awful.key(act))
end

local exit_screen_grabber = awful.keygrabber {
    -- auto_start = true,
    mask_modkeys = true,
    stop_event = 'press',
    timeout = 7,
    timeout_callback = function()
        awesome.emit_signal('module::exit_screen:hide')
    end,
    stop_callback = function()
        awesome.emit_signal('module::exit_screen:hide')
    end,
    keybindings = exit_keys,
    -- stop_key triggered before keybindings work
    -- so one cannot put keys in keybindings to stop_keys
    stop_key = cancel_action.keys
}

screen.connect_signal('request::desktop_decoration', create_exit_screen)
-- screen.connect_signal('removed', create_exit_screen)

awesome.connect_signal(
    'module::exit_screen:show', function()
    for s in screen do
        s.exit_screen.visible = false
    end
    awful.screen.focused().exit_screen.visible = true
    exit_screen_grabber:start()
end)

awesome.connect_signal(
    'module::exit_screen:hide', function()
    -- exit_screen_grabber:stop()
    for s in screen do
        s.exit_screen.visible = false
    end
end)
