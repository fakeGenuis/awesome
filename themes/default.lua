--  _____ _  _ ___ __  __ ___
-- |_   _| || | __|  \/  | __|
--   | | | __ | _|| |\/| | _|
--   |_| |_||_|___|_|  |_|___|
local dpi = require("beautiful.xresources").apply_dpi
local conf_dir = require("gears.filesystem").get_configuration_dir()
local layout_icons_path = conf_dir .. "icons/layout/"
-- `luarocks install toml`
local toml = require("toml")
local _, theme_conf = pcall(toml.decode, io.open(
    conf_dir .. "themes/default.toml", "rb"):read "*a")

-- Fonts, colors and others
local theme = {}
for _, conf in pairs({ "fonts", "others" }) do
    for k, v in pairs(theme_conf[conf]) do theme[k] = v end
end

-- Fonts in awesome themelib
theme.hotkeys_font             = theme.mono_font
theme.hotkeys_description_font = theme.font_alt

-- Colors in awesome themelib
theme.bg_normal   = theme_conf.colors.background
theme.bg_focus    = theme_conf.colors.selected
theme.bg_urgent   = theme_conf.colors.urgent
theme.bg_minimize = theme_conf.colors.active
theme.fg_normal   = theme_conf.colors.foreground
theme.fg_focus    = theme_conf.colors.foreground_alt
theme.fg_urgent   = theme_conf.colors.foreground_alt

theme.wibar_bg           = theme.transparen
theme.wibox_border_color = theme.transparen
theme.bg_systray         = theme.bg_minimize
theme.bg_button          = theme_conf.colors.background_alt

theme.border_color_normal = theme.bg_normal
theme.border_color_active = theme.bg_focus
theme.border_color_marked = theme.bg_normal

-- Distances
for k, v in pairs(theme_conf.distances) do theme[k] = dpi(v) end

-- Distances in awesome themelib
theme.margin_spacing       = theme.margin
theme.systray_icon_spacing = theme.spacing_alt
theme.notification_spacing = 2 * theme.useless_gap
-- Custom distances
theme.topbar_height        = theme.icon_size

-- Tasklist clients title prefixes
for k, v in pairs(theme_conf.tasklist_prefixs) do theme["tasklist_" .. k] = v end

-- Layouts
for _, k in pairs({
    "fairh", "fairv", "floating", "magnifier", "max", "fullscreen",
    "tilebottom", "tileleft", "tile", "tiletop", "spiral", "dwindle"
}) do theme["layout_" .. k] = layout_icons_path .. k .. ".png" end

return theme
