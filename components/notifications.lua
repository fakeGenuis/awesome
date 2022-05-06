--   _   _    ___    _____   ___   _____   ___    ____      _      _____   ___
--  | \ | |  / _ \  |_   _| |_ _| |  ___| |_ _|  / ___|    / \    |_   _| |_ _|
--  |  \| | | | | |   | |    | |  | |_     | |  | |       / _ \     | |    | |
--  | |\  | | |_| |   | |    | |  |  _|    | |  | |___   / ___ \    | |    | |
--  |_| \_|  \___/    |_|   |___| |_|     |___|  \____| /_/   \_\   |_|   |___|
--
--    ___    _   _
--   / _ \  | \ | |
--  | | | | |  \| |
--  | |_| | | |\  |
--   \___/  |_| \_|
-- ===================================================================
-- Initialization
-- ===================================================================
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local menubar = require("menubar")
local mywidgets = require("mywidgets")
local markup = require("lain").util.markup

-- naughty.config.padding = 2*beautiful.useless_gap
naughty.config.icon_dirs = {"/usr/share/icons/Papirus/", "~/.local/share/icons/"}
-- naughty.config.icon_formats = {"png", "svg", "jpg"}
--
naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.timeout = 7
--
-- naughty.config.presets.normal = {
--     fg = beautiful.fg_focus,
--     bg = beautiful.bg_focus
-- }
--
-- naughty.config.presets.low = {
--     fg = beautiful.fg_normal,
--     bg = beautiful.bg_normal
-- }
--
-- naughty.config.presets.critical = {
--     fg = beautiful.fg_urgent,
--     bg = beautiful.bg_urgent,
--     timeout = 0
-- }

-- notification icon
naughty.connect_signal('request::icon', function(n, context, hints)
    if context ~= 'app_icon' then return end

    local path = menubar.utils.lookup_icon(hints.app_icon) or
                     menubar.utils.lookup_icon(hints.app_icon:lower())

    if path then n.icon = path end
end)

naughty.connect_signal('request::display', function(n)
    local app_icon = nil
    if n.app_icon and n.app_icon ~= '' then
        app_icon = n.app_icon
    elseif n.image and n.image ~= '' then
        app_icon = n.image
    end

    n.title = markup.font(beautiful.title_font, n.title)
    n.message = markup.font(beautiful.message_font, n.message)

    local app_icon_box = nil
    if app_icon then
        app_icon_box = wibox.widget {
            image = app_icon,
            resize = true,
            forced_height = dpi(16),
            forced_width = dpi(16),
            widget = wibox.widget.imagebox
        }
    end

    local app_name = mywidgets.icon_text(n.app_name or "System Notification")
    app_name.font = beautiful.lowlevel_font

    -- local dismiss_button = mywidgets.block {mywidgets.icon_text("󰅙")}
    -- dismiss_button:connect_signal("button::press", function(_, _, _, button)
    --     if button == 1 then n:destroy(nil, 1) end
    -- end)

    local app_name_and_icon = wibox.widget {
        nil,
        app_name,
        app_icon_box,
        -- dismiss_button,
        expand = "inside",
        layout = wibox.layout.align.horizontal
    }

    local text_widget = mywidgets.icon_text()
    text_widget.id = "text_role"
    text_widget.font = beautiful.font

    local action_list = wibox.widget {
        notification = n,
        base_layout = wibox.widget {
            spacing = beautiful.spacing,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = mywidgets.block (text_widget),
        style = {
            bg_normal = beautiful.bg_normal,
            bg_selected = beautiful.bg_focus
        },
        widget = naughty.list.actions
    }

    local notify_box = mywidgets.block({
        app_name_and_icon,
        {
            {
                {
                    resize_strategy = "center",
                    focus_height = dpi(32),
                    focus_width = dpi(32),
                    widget = naughty.widget.icon
                },
                widget = wibox.container.place
            },
            {
                naughty.widget.title,
                naughty.widget.message,
                spacing = beautiful.spacing,
                layout = wibox.layout.fixed.vertical
            },
            spacing = beautiful.spacing,
            layout = wibox.layout.fixed.horizontal
        },
        action_list,
        layout = wibox.layout.fixed.vertical
    })

    naughty.layout.box {
        notification = n,
        type = 'notification',
        hide_on_right_click = true,
        placement = awful.placement.top_right,
        shape = mywidgets.shape,
        widget_template = notify_box
    }
end)
