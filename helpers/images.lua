local gfs         = require("gears").filesystem
local menubar     = require("menubar")
local lookup_icon = menubar.utils.lookup_icon
local wibox       = require("wibox")
local mywidgets   = require("helpers.mywidgets")
local beautiful   = require("beautiful")
local dpi         = beautiful.xresources.apply_dpi

local images = {}

function images.get_icon(icon_name, args)
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

function images.image_desc_box(act, args)
    local image_size = args.image_size or dpi(64)
    local prefix = args.prefix or ""

    local image_box = wibox.widget {
        -- clip_shape    = gears.shape.circle,
        forced_height = image_size,
        forced_width  = image_size,
        image         = images.get_icon(act.icon_name, { prefix = prefix }),
        resize        = true,
        widget        = wibox.widget.imagebox
    }

    local desc_box = mywidgets.block(
        mywidgets.textbox { markup = act.name, font = beautiful.key_font },
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
        spacing = 2 * beautiful.spacing,
        layout = wibox.layout.fixed.vertical
    }

    return box
end

return images
