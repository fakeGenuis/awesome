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
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local menubar = require("menubar")
local mywidgets = require("mywidgets")

-- naughty.config.padding = dpi(7)
-- naughty.config.spacing = dpi(7)
naughty.config.icon_dirs = {"Papirus"}
-- naughty.config.icon_formats = {"png", "svg", "jpg"}
--
naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.timeout = 7
naughty.config.defaults.position = 'bottom_right'
naughty.config.defaults.shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(7))
end
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

naughty.connect_signal('request::icon', function(n, context, hints)
    if context ~= 'app_icon' then return end

    local path = menubar.utils.lookup_icon(hints.app_icon) or
                     menubar.utils.lookup_icon(hints.app_icon:lower())

    if path then n.icon = path end
end)

naughty.connect_signal('request::display', function(n)
    local app_icon = function()
        if n.app_icon and n.app_icon ~= '' then
            return n.app_icon
        elseif n.image and n.image ~= '' then
            return n.image
        else
            return nil
        end
    end

    local app_icon_box = nil
    if app_icon() then
        app_icon_box = wibox.widget {
            image = app_icon(),
            resize = true,
            forced_height = dpi(16),
            forced_width = dpi(16),
            widget = wibox.widget.imagebox
        }
    end

    local app_name = mywidgets.icon_text(n.app_name or "System Notification")
    app_name.font = beautiful.font

    -- local dismiss_button = mywidgets.block {mywidgets.icon_text("󰅙")}
    -- dismiss_button:connect_signal("button::press", function(_, _, _, button)
    --     if button == 1 then n:destroy(nil, 1) end
    -- end)

    local app_icon_with_name_and_dismiss_btn = wibox.widget {
        app_icon_box,
        app_name,
        -- dismiss_button,
        expand = "inside",
        spacing = beautiful.spacing,
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
        widget_template = mywidgets.block {text_widget},
        style = {
            bg_normal = beautiful.bg_normal,
            bg_selected = beautiful.bg_focus
        },
        widget = naughty.list.actions
    }

    local notify_box = mywidgets.block({
            app_icon_with_name_and_dismiss_btn,
            {
            {
                resize_strategy = "center",
                widget = naughty.widget.icon,
                focus_height = dpi(32),
                focus_width = dpi(32)
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
        aciton_list,
        layout = wibox.layout.fixed.vertical
    }, {bg = beautiful.bg_popup})

    naughty.layout.box {
        notification = n,
        widget_template = {
            notify_box,
            strategy = "max",
            width = beautiful.notification_max_width,
            widget = wibox.container.constraint,
            opacity = 0.7,
        }
    }
end)
