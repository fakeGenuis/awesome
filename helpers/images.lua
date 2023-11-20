local gfs         = require("gears").filesystem
local menubar     = require("menubar")
local lookup_icon = menubar.utils.lookup_icon
local wibox       = require("wibox")
local mywidgets   = require("helpers.mywidgets")
local beautiful   = require("beautiful")
local dpi         = beautiful.xresources.apply_dpi

local images = {}

function images.get_icon(icon_name, args)
    local args = args or {}
    local prefix = args.prefix or ""
    local icon_path

    for _, ext in pairs({ "png", "jpg", "svg" }) do
        icon_path = string.format('%sicons/%s.%s',
            gfs.get_configuration_dir(), icon_name, ext)
        if gfs.file_readable(icon_path) then
            return icon_path
        end
    end

    icon_path = lookup_icon(icon_name) or lookup_icon(prefix .. icon_name)
    if icon_path then return icon_path end

    return icon_name
end

function images.image_desc_box(act, args)
    local args = args or {}
    local image_size = args.image_size or dpi(64)
    local prefix = args.prefix or ""
    local layout = args.layout or wibox.layout.fixed.vertical

    local image_box = act.icon_name and wibox.widget {
        -- clip_shape    = gears.shape.circle,
        forced_height = image_size,
        forced_width  = image_size,
        image         = images.get_icon(act.icon_name, { prefix = prefix }),
        resize        = true,
        widget        = wibox.widget.imagebox
    } or nil

    local desc_box = mywidgets.block(
        mywidgets.textbox { markup = act.name, font = beautiful.mono_font },
        { bg = beautiful.bg_button, fg = beautiful.fg_button }
    )

    local box = wibox.widget {
        { image_box, widget = wibox.container.place },
        {
            desc_box,
            widget = wibox.container.place
        },
        spacing = beautiful.spacing,
        layout = layout
    }

    return box
end

return images
