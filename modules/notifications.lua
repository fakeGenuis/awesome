--  _   _       _   _  __ _           _   _
-- | \ | | ___ | |_(_)/ _(_) ___ __ _| |_(_) ___  _ __
-- |  \| |/ _ \| __| | |_| |/ __/ _` | __| |/ _ \| '_ \
-- | |\  | (_) | |_| |  _| | (_| (_| | |_| | (_) | | | |
-- |_| \_|\___/ \__|_|_| |_|\___\__,_|\__|_|\___/|_| |_|
-- ===================================================================
-- Initialization
-- ===================================================================
local awful                       = require("awful")
local wibox                       = require("wibox")
local naughty                     = require("naughty")
local beautiful                   = require("beautiful")
local dpi                         = beautiful.xresources.apply_dpi
local menubar                     = require("menubar")
local get_icon                    = menubar.utils.lookup_icon
local mw                          = require("helpers.mywidgets")
local markup                      = require("lain").util.markup
local images                      = require("helpers.images")
local gfs                         = require("gears.filesystem")

-- naughty.config.padding = 2*beautiful.useless_gap
naughty.config.icon_dirs          = {
    "/usr/share/icons/Papirus/", "~/.local/share/icons/"
}
-- naughty.config.icon_formats = {"png", "svg", "jpg"}
naughty.config.sound_dirs         = {
    "/usr/share/sounds/freedesktop/stereo/"
}
naughty.config.sound_formats      = { "oga" }
--
naughty.config.defaults.ontop     = true
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.timeout   = 7
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

local function notify_box(n)
    local app_icon = nil
    if n.app_icon then
        app_icon = get_icon(n.app_icon) or get_icon(n.app_icon:lower())
    elseif n.app_name then
        app_icon = get_icon(n.app_name) or get_icon(n.app_name:lower())
    end

    local app_icon_box = app_icon and wibox.widget {
        image = app_icon,
        resize = true,
        forced_height = beautiful.topbar_height,
        forced_width = beautiful.topbar_height,
        widget = wibox.widget.imagebox
    } or nil

    local app_name_box = mw.textbox {
        markup = n.app_name or "System Notification",
        font = beautiful.light_font
    }

    local notify_top = wibox.widget {
        app_icon_box,
        app_name_box,
        mw.textbox { markup = n.date, font = beautiful.light_font },
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
        },
        widget = naughty.list.actions
    }

    local box = {
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

    return box
end

function naughty.config.notify_callback(args)
    local sound_name = (args.freedesktop_hints and args.freedesktop_hints["sound-name"]) or
        "message"
    local sound_file = args.freedesktop_hints and args.freedesktop_hints["sound-file"] or
        nil
    if not sound_file then
        for _, dir in pairs(naughty.config.sound_dirs) do
            for _, ext in pairs(naughty.config.sound_formats) do
                sound_file = dir .. sound_name .. "." .. ext
                if gfs.file_readable(sound_file) then
                    break
                end
            end
        end
    end
    awful.spawn { "paplay", sound_file }
    return args
end

naughty.connect_signal('request::display', function(n)
    n.date = os.date("%H:%M")
    n.title = markup.font(beautiful.bold_font, n.title)
    n.message = markup.font(beautiful.light_font,
        n.message)

    naughty.layout.box {
        notification = n,
        type = 'notification',
        hide_on_right_click = true,
        maximum_width = dpi(350),
        minimum_width = dpi(200),
        placement = awful.placement.top_right,
        shape = mw.shape,
        widget_template = mw.block {
            notify_box(n),
            -- top = beautiful.margin_spacing,
            -- bottom = beautiful.margin_spacing,
            margins = beautiful.margin_spacing,
            widget = wibox.container.margin
        }
    }
end)

local notif_wb = wibox {
    widget  = {},
    ontop   = true,
    visible = false,
    type    = 'splash',
    width   = dpi(300),
    height  = dpi(500),
    x       = (awful.screen.focused().geometry.width - dpi(300)) / 2,
    y       = beautiful.topbar_height + beautiful.margin_spacing +
        2 * beautiful.useless_gap,
    shape   = mw.shape,
    bg      = beautiful.transparen
}

notif_wb:setup {
    {
        nil,
        {
            {
                widget = naughty.list.notifications,
                filter = naughty.list.notifications.filter.all,
                widget_template = {
                    widget = wibox.container.margin,
                    margins = beautiful.margin_spacing,
                    create_callback = function(self, n, _, _)
                        self:set_widget(mw.block(
                            notify_box(n)
                        ))
                    end
                }
            },
            layout = wibox.layout.fixed.vertical
        },
        {
            images.image_desc_box({ name = "clean", icon_name = "sweeping" },
                {
                    layout = wibox.layout.fixed.horizontal,
                    image_size = beautiful.icon_size
                }),
            halign = 'right',
            widget = wibox.container.place
        },
        layout = wibox.layout.align.vertical
    },
    margins = beautiful.margin_spacing,
    widget = wibox.container.margin
}

awesome.connect_signal("module::notification:toggle", function()
    notif_wb.visible = not notif_wb.visible
end)
