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
local awful     = require("awful")
local wibox     = require("wibox")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi
local menubar   = require("menubar")
local get_icon  = menubar.utils.lookup_icon
local mw        = require("helpers.mywidgets")
local markup    = require("lain").util.markup

-- naughty.config.padding = 2*beautiful.useless_gap
naughty.config.icon_dirs = {
    "/usr/share/icons/Papirus/", "~/.local/share/icons/"
}
-- naughty.config.icon_formats = {"png", "svg", "jpg"}
--
naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.timeout = 7
--
-- naughty.config.presets.normal = {
--   fg = beautiful.fg_focus,
--   bg = beautiful.bg_focus
-- }

-- naughty.config.presets.low = {
--   fg = beautiful.fg_normal,
--   bg = beautiful.bg_normal
-- }

-- naughty.config.presets.critical = {
--   fg = beautiful.fg_urgent,
--   bg = beautiful.bg_urgent,
--   timeout = 0
-- }

-- notification icon
-- naughty.connect_signal('request::icon', function(n, context, hints)
--   if context ~= 'icon' then return end

--   local path = get_icon(hints.icon) or get_icon(hints.icon:lower())

--   if path then n.icon = path end
-- end)

naughty.connect_signal('request::display', function(n)
    local app_icon = nil
    if n.app_icon then
        app_icon = get_icon(n.app_icon) or get_icon(n.app_icon:lower())
    elseif n.app_name then
        app_icon = get_icon(n.app_name) or get_icon(n.app_name:lower())
    end

    n.title = markup.font(beautiful.bold_font, n.title)
    n.message = markup.font(beautiful.small_font, n.message)

    local app_icon_box = nil
    if app_icon then
        app_icon_box = wibox.widget {
            image = app_icon,
            resize = true,
            forced_height = beautiful.topbar_height,
            forced_width = beautiful.topbar_height,
            widget = wibox.widget.imagebox
        }
    end

    local app_name = mw.textbox {
        markup = n.app_name or "System Notification"
    }
    app_name.font = beautiful.small_font


    n.date = os.date("%H:%M")
    local notify_top = wibox.widget {
        app_icon_box,
        app_name,
        mw.textbox { markup = n.date, font = beautiful.small_font },
        expand = "inside",
        layout = wibox.layout.align.horizontal
    }

    local action_list = wibox.widget {
        notification = n,
        base_layout = wibox.widget {
            spacing = beautiful.spacing,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                mw.textbox { id = "text_role", font = beautiful.font },
                left = beautiful.margin_spacing,
                right = beautiful.margin_spacing,
                widget = wibox.container.margin
            },
            widget = mw.clickable
        },
        style = {
            underline_normal = false,
            underline_selected = true,
            fg_normal = beautiful.fg_focus,
            -- bg_normal = beautiful.bg_button
            -- bg_selected        = beautiful.bg_focus,
            -- fg_selected        = beautiful.fg_focus
        },
        widget = naughty.list.actions
    }

    local notify_box = {
        notify_top,
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
            spacing = 2 * beautiful.spacing,
            layout = wibox.layout.fixed.horizontal
        },
        {
            action_list,
            widget = wibox.container.place
        },
        spacing = beautiful.spacing,
        layout = wibox.layout.fixed.vertical
    }

    naughty.layout.box {
        notification = n,
        type = 'notification',
        hide_on_right_click = true,
        maximum_width = dpi(350),
        minimum_width = dpi(200),
        placement = awful.placement.top_right,
        shape = mw.shape,
        widget_template = mw.block {
            notify_box,
            top = beautiful.margin_spacing,
            bottom = beautiful.margin_spacing,
            widget = wibox.container.margin
        }
    }
end)
