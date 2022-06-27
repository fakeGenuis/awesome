--  _____   _   _   _____   __  __   _____
-- |_   _| | | | | | ____| |  \/  | | ____|
--   | |   | |_| | |  _|   | |\/| | |  _|
--   | |   |  _  | | |___  | |  | | | |___
--   |_|   |_| |_| |_____| |_|  |_| |_____|
local dpi = require("beautiful.xresources").apply_dpi
local layout_icons_path = require("gears.filesystem").get_configuration_dir() ..
    "icons/layout/"

-- BASICS
local theme = {}
theme.font = "Sarasa Gothic SC 14"
theme.bold_font = "Sarasa Gothic SC Semi-Bold 14"
theme.small_font = "Sarasa UI SC 12"
theme.iconfont = "Material Design Icons 16"
-- specific a monospace font for representing key
theme.key_font = "mononoki Nerd Font Mono 16"
theme.icon_theme = "Papirus"
theme.wallpaper = "~/Pictures/Wallpapers/www.acg.gy_66.jpg"

theme.transparen  = "#00000000"
theme.bg_normal   = "#cae1ff"
theme.bg_focus    = "#4876ff"
theme.bg_urgent   = "#fce94f"
theme.bg_minimize = "#9f79ee"
theme.bg_button   = "#63b8ff"

theme.fg_normal = "#000000"
theme.fg_focus = "#ffffff"
theme.fg_urgent = "#ff0051"
theme.fg_minimize = theme.fg_focus

theme.wibar_bg = theme.transparen
theme.wibox_border_color = theme.transparen
theme.bg_systray = theme.bg_minimize

theme.systray_icon_spacing = dpi(1)
theme.topbar_height = dpi(23)
theme.spacing = dpi(3)
theme.margin_spacing = dpi(2)
theme.taglist_spacing = dpi(3)
theme.tasklist_spacing = dpi(3)

theme.useless_gap = dpi(4)
theme.border_width = dpi(0)
theme.border_color_normal = theme.bg_normal
theme.border_color_active = theme.bg_focus
theme.border_color_marked = theme.bg_normal

theme.taglist_fg_focus = theme.fg_focus
theme.taglist_bg_focus = theme.bg_focus
theme.taglist_fg_occupied = theme.fg_normal
theme.taglist_bg_occupied = theme.bg_normal

theme.tasklist_floating = " "
theme.tasklist_maximized = " "
theme.tasklist_ontop = " "
theme.tasklist_above = " "
theme.tasklist_below = " "

theme.hotkeys_opacity = 0.75
-- theme.hotkeys_bg = "#292d3e" default bg_normal
-- theme.hotkeys_fg = "#eeffff" default fg_normal
theme.hotkeys_font = "mononoki Nerd Font Mono 14"
theme.hotkeys_description_font = "Comic Shanns 13"

-- LAYOUT
theme.layout_fairh = layout_icons_path .. "fairh.png"
theme.layout_fairv = layout_icons_path .. "fairv.png"
theme.layout_floating = layout_icons_path .. "floating.png"
theme.layout_magnifier = layout_icons_path .. "magnifier.png"
theme.layout_max = layout_icons_path .. "max.png"
theme.layout_fullscreen = layout_icons_path .. "fullscreen.png"
theme.layout_tilebottom = layout_icons_path .. "tilebottom.png"
theme.layout_tileleft = layout_icons_path .. "tileleft.png"
theme.layout_tile = layout_icons_path .. "tile.png"
theme.layout_tiletop = layout_icons_path .. "tiletop.png"
theme.layout_spiral = layout_icons_path .. "spiral.png"
theme.layout_dwindle = layout_icons_path .. "dwindle.png"

-- NOTIFICATION
-- theme.notification_margin = dpi(16)
-- theme.notification_opacity = 1
-- theme.notification_border_width = dpi(2)
-- theme.notification_border_color = theme.tp
theme.notification_spacing = 2 * theme.useless_gap

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
