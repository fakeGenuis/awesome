--     _     __        __  _____   ____     ___    __  __   _____
--    / \    \ \      / / | ____| / ___|   / _ \  |  \/  | | ____|
--   / _ \    \ \ /\ / /  |  _|   \___ \  | | | | | |\/| | |  _|
--  / ___ \    \ V  V /   | |___   ___) | | |_| | | |  | | | |___
-- /_/   \_\    \_/\_/    |_____| |____/   \___/  |_|  |_| |_____|
-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title = "Oops, an error happened" ..
            (startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- {{{ Autostart
awful.spawn.with_shell("~/.config/awesome/scripts/autostart.sh")
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "/themes/default.lua")
-- Wallpaper at awesome start
for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
end

-- define default apps (global variable so other components can access it)
apps = {
    network_manager = "", -- recommended: nm-connection-editor
    power_manager = "", -- recommended: xfce4-power-manager
    power_menu = "rofi -show p -modi p:~/.config/awesome/scripts/rofi-power-menu -theme power-menu", -- recommended: xfce4-power-manager
    terminal = "alacritty",
    editor = os.getenv("VISUAL") or os.getenv("EDITOR"),
    launcher = "rofi -show combi",
    lock = "myi3lock",
    browser = "librewolf",
    screenshot = "spectacle",
    filebrowser = "alacritty -e ranger"
}
-- }}}

-- {{{ Tag
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.max, awful.layout.suit.tile,
        awful.layout.suit.floating
    })
end)
-- }}}

-- {{{ Wibar
require("components.topbar")
-- only wallpaper remain when windows fullscreen
-- with transparency
client.connect_signal("property::fullscreen", function(c)
    local s = awful.screen.focused()
    local t = s.selected_tag
    if c.class == 'Emacs' or c.class == 'emacs' then
        if c.fullscreen then
            s.mywibox.visible = false
            for _, c1 in ipairs(t:clients()) do
                if c1 ~= client.focus and not c1.minimized then
                    c1.minimized = true
                    c1.visible_mark = true
                end
            end
        else
            s.mywibox.visible = true
            for _, c1 in ipairs(t:clients()) do
                if c1.visible_mark then
                    c1.minimized = false
                    c1.visible_mark = false
                end
            end
        end
    end
end)
-- }}}

-- {{{ Key and Mouse bindings
local keys = require("components.keys")
-- awful.keyboard.append_global_keybindings(keys.globalkeys)
-- General Awesome keys and buttons
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)
-- client related keys and buttons
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings(keys.clientmouse)
end)
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings(keys.clientkeys)
end)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
require("components.rules")
-- }}}

-- {{{ Notifications
require("components.notifications")

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule = {},
        properties = {screen = awful.screen.preferred, implicit_timeout = 5}
    }
end)

naughty.notification {
    title = 'Welcome',
    message = 'Awesome WM is started',
    icon = beautiful.awesome_icon,
    urgency = 'normal'
}
-- }}}
