-- local lookup_icon = menubar.utils.lookup_icon
-- local menubar     = require("menubar")
local awful        = require("awful")
local beautiful    = require("beautiful")
local dpi          = beautiful.xresources.apply_dpi
local gears        = require("gears")
local gfs          = require("gears").filesystem
local generate_key = require("helpers.generate_key")
local menubar      = require("menubar")
local lookup_icon  = menubar.utils.lookup_icon
local mywidgets    = require("mywidgets")
local wibox        = require("wibox")

local actions = {
    reload = {
        name = "reload",
        icon_name = "reload",
        command = awesome.restart
    },
    sleep = {
        name = "sleep",
        icon_name = "suspend",
        command = "systemctl suspend"
    },
    reboot = {
        name = "reboot",
        icon_name = "reboot",
        command = "systemctl reboot"
    },
    lock = {
        name = "lock",
        icon_name = "lock-screen",
        command = function(self)
            -- stop key grabber first for betterlockscreen (i3lock) to work
            -- otherwise: `i3lock: Cannot grab pointer/keyboard`
            self:stop()
            awful.spawn("betterlockscreen -l")
        end,
    },
    logout = {
        name = "logout",
        icon_name = "log-out",
        command = awesome.quit
    },
    shutdown = {
        name = "shutdown",
        icon_name = "shut-down",
        command = "systemctl poweroff"
    },
}

local cancel_action = {
    name = "cancel",
    modifiers = {},
    keys = { "q", "c", "Escape" },
    -- <a target="_blank" href="https://icons8.com/icon/63688/cancel">Cancel</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
    icon_name = "cancel"
}

local profile_action = {
    name = os.getenv("USER"),
    icon_name = os.getenv("HOME") .. "/.face"
}

local existed = {}
for _, i in pairs(cancel_action.keys) do
    existed[string.byte(i)] = true
end

for _, act in pairs(actions) do
    generate_key(act, existed, { modifiers = {} })
end

local get_icon = function(icon_name, args)
    local prefix = args.prefix or ""
    local icon_path = lookup_icon(icon_name) or lookup_icon(prefix .. icon_name)
    if icon_path then return icon_path end

    for _, ext in pairs({ "png", "jpg" }) do
        icon_path = string.format('%sicons/%s.%s',
            gfs.get_configuration_dir(), icon_name, ext)
        if gfs.file_readable(icon_path) then
            return icon_path
        end
    end

    return icon_name
end

local image_desc_box = function(act)
    local image_box = wibox.widget {
        clip_shape    = gears.shape.circle,
        forced_height = dpi(96),
        forced_width  = dpi(96),
        image         = get_icon(act.icon_name, { prefix = "system-" }),
        resize        = true,
        widget        = wibox.widget.imagebox
    }

    local desc_box = mywidgets.block(
        mywidgets.textbox { markup = act.name },
        { bg = beautiful.bg_button }
    )

    local box = wibox.widget {
        { image_box, widget = wibox.container.place },
        {
            {
                desc_box,
                left = beautiful.margin_spacing,
                right = beautiful.margin_spacing,
                widget = wibox.container.margin
            },
            widget = wibox.container.place
        },
        spacing = beautiful.spacing,
        layout = wibox.layout.fixed.vertical
    }

    return box
end

local create_exit_screen = function(s)
    s.exit_screen = wibox {
        bg        = beautiful.transparen,
        fg        = beautiful.fg_normal,
        height    = s.geometry.height,
        ontop     = true,
        opacity   = 0.75,
        placement = awful.placement.center,
        type      = 'splash',
        visible   = false,
        widget    = {},
        width     = s.geometry.width,
        x         = s.geometry.x,
        y         = s.geometry.y
    }

    local action_boxs = {}
    for _, act in pairs(actions) do
        table.insert(action_boxs, image_desc_box(act))
    end
    action_boxs.layout = wibox.layout.fixed.horizontal
    action_boxs.spacing = dpi(96)

    local profile_box = image_desc_box(profile_action)
    local cancel_box = image_desc_box(cancel_action)

    s.exit_screen:setup {
        {
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(64),
            profile_box,
            action_boxs,
            cancel_box
        }, widget = wibox.container.place }

    s.exit_screen:buttons(gears.table.join(awful.button({}, 2, function()
        awesome.emit_signal('module::exit_screen:hide')
    end), awful.button({}, 3, function()
        awesome.emit_signal('module::exit_screen:hide')
    end)))
end

local exit_keys = {}

for _, act in pairs(actions) do
    if type(act.command) == "function" then
        act.on_press = act.command
    elseif type(act.command) == "string" then
        act.on_press = function()
            awful.spawn(act.command)
        end
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
    'module::exit_screen:show',
    function()
        for s in screen do
            s.exit_screen.visible = false
        end
        awful.screen.focused().exit_screen.visible = true
        exit_screen_grabber:start()
    end
)

awesome.connect_signal(
    'module::exit_screen:hide',
    function()
        -- exit_screen_grabber:stop()
        for s in screen do
            s.exit_screen.visible = false
        end
    end
)
