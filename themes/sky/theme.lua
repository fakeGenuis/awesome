-------------------------------
--    "Sky" awesome theme    --
--  By Andrei "Garoth" Thorp --
-------------------------------
-- If you want SVGs and extras, get them from garoth.com/awesome/sky-theme

local theme_assets = require("beautiful.theme_assets")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local dpi = xresources.apply_dpi
local layout_icons_path = require("gears.filesystem").get_configuration_dir() .. "icons/"


-- BASICS
local theme = {}
theme.font          = "Sarasa Gothic SC 14"

theme.bg_focus      = "#d1cbc000"
theme.bg_normal     = "#c6e2ff00"
theme.bg_urgent     = "#ff0051"
theme.bg_minimize   = "#dfc2b2"

theme.bg_systray    = nil
theme.systray_icon_spacing = dpi(5)

theme.fg_normal     = "#2e3436"
theme.fg_focus      = "#1aa698"
theme.fg_urgent     = "#ff0051"
theme.fg_minimize   = "#2e3436"

theme.useless_gap   = dpi(4)
theme.border_width  = dpi(2)
theme.border_color_normal = "#dae3e0"
theme.border_color_active = "#729fcf"
theme.border_color_marked = "#eeeeec"

theme.tasklist_floating = " "
theme.tasklist_maximized = " "
theme.tasklist_ontop = " "
theme.tasklist_above = " "
theme.tasklist_below = " "

-- IMAGES
theme.layout_fairh           = layout_icons_path .. "fairh.png"
theme.layout_fairv           = layout_icons_path .. "fairv.png"
theme.layout_floating        = layout_icons_path .. "floating.png"
theme.layout_magnifier       = layout_icons_path .. "magnifier.png"
theme.layout_max             = layout_icons_path .. "max.png"
theme.layout_fullscreen      = layout_icons_path .. "fullscreen.png"
theme.layout_tilebottom      = layout_icons_path .. "tilebottom.png"
theme.layout_tileleft        = layout_icons_path .. "tileleft.png"
theme.layout_tile            = layout_icons_path .. "tile.png"
theme.layout_tiletop         = layout_icons_path .. "tiletop.png"
theme.layout_spiral          = layout_icons_path .. "spiral.png"
theme.layout_dwindle         = layout_icons_path .. "dwindle.png"

-- Set different colors for urgent notifications.
rnotification.connect_signal('request::rules', function()
    rnotification.append_rule {
        rule       = { urgency = 'critical' },
        properties = { bg = '#ff0000', fg = '#ffffff' }
    }
end)

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
