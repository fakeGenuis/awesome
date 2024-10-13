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
    }, {
        name      = "suspend",
        icon_name = "sleep",
        command   = "systemctl suspend"
    }, {
        name      = "hibernation",
        icon_name = "hibernation",
        command   = "systemctl hibernate"
    }, {
        name      = "reboot",
        icon_name = "reboot",
        command   = "systemctl reboot"
    }, {
        name      = "lock",
        icon_name = "lock-screen",
        command   = function(self)
            -- stop key grabber first for betterlockscreen (i3lock) to work
            -- otherwise: `i3lock: Cannot grab pointer/keyboard`
            self:stop()
            awful.spawn(APPS.lock_screen)
        end,
    }, {
        name      = "logout",
        icon_name = "log-out",
        command   = function(self)
            self:stop()
            awesome.quit()
        end
    }, {
        name      = "shutdown",
        icon_name = "shut-down",
        command   = "systemctl poweroff"
    }
}

local profile_action = {
    name      = os.getenv("USER"),
    icon_name = string.format("/var/lib/AccountsService/icons/%s.face.icon", os.getenv("USER"))
}

local existed = {}
-- update actions by add act.key and act.name
for _, act in ipairs(actions) do
    generate_key(act, existed, { modifiers = {} })
end

local create_exit_screen = function(s)
    s.exit_screen = wibox {
        bg        = beautiful.transparen,
        ontop     = true,
        opacity   = 0.75,
        placement = awful.placement.center,
        type      = 'splash',
        visible   = false,
        widget    = {},
        height    = s.geometry.height,
        width     = s.geometry.width,
    }

    local action_boxs = wibox.layout.fixed.horizontal()
    for _, act in ipairs(actions) do
        action_boxs:add(images.image_desc_box(act, { prefix = "system-" }))
    end
    action_boxs.spacing = dpi(64)

    local profile_box = images.image_desc_box(profile_action, { image_size = dpi(96) })

    s.exit_screen:setup { {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(64),
        profile_box,
        action_boxs
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
    timeout = 7,
    -- stop_key triggered before keybindings work
    -- so one cannot put keys in keybindings to stop_keys
    stop_key = "Escape",
    stop_event = 'press',
    stop_callback = function()
        awesome.emit_signal('module::exit_screen:hide')
    end,
    keybindings = exit_keys
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
    for s in screen do
        s.exit_screen.visible = false
    end
end)
