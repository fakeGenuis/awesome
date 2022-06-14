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
local menubar = require("menubar")

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

scripts_dir = gears.filesystem.get_configuration_dir() .. "scripts/"

-- {{{ Autostart
awful.spawn.with_shell(scripts_dir .. "autostart.sh")
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
    -- power_menu = "rofi -show p -modi p:" .. scripts_dir ..
    --     "rofi-power-menu -theme power-menu", -- recommended: xfce4-power-manager
    power_menu = scripts_dir .. "power.fish",
    terminal = "alacritty",
    editor = os.getenv("VISUAL") or os.getenv("EDITOR"),
    launcher = "rofi -show combi",
    browser = "librewolf -p work",
    screenshot = scripts_dir .. "screenshot.fish",
    filebrowser = "emacsclient -nc -e '(dirvish)'",
    dark_toggle = scripts_dir .. "switcher.fish"
}
-- }}}

-- {{{ Tag
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.max,
        awful.layout.suit.fair, awful.layout.suit.floating
        , awful.layout.suit.max.fullscreen
    })
end)
-- }}}

-- https://www.reddit.com/r/awesomewm/comments/bva8t2/comment/epn7rf1/?utm_source=share&utm_medium=web2x&context=3
client.connect_signal("manage", function(c)
    local icon, lower_icon

    if c.instance then
        icon = menubar.utils.lookup_icon(c.instance)
        lower_icon = menubar.utils.lookup_icon(c.instance:lower())
    end

    local new_icon

    -- Check if the icon exists
    if icon ~= nil then
        new_icon = gears.surface(icon)

        -- Check if the icon exists in the lowercase variety
    elseif lower_icon ~= nil then
        new_icon = gears.surface(lower_icon)

        -- Check if the client already has an icon. If not, give it a default.
    elseif c.icon == nil then
        new_icon = gears.surface(menubar.utils.lookup_icon("unknown"))
    end

    if new_icon then
        c.icon = new_icon._native
    end
end)

-- {{{ Wibar
require("components.topbar")
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
        properties = { screen = awful.screen.preferred, implicit_timeout = 5 }
    }
end)

naughty.notification {
    title = 'Welcome',
    message = 'Awesome WM is started',
    app_icon = "Diana-Circle",
    app_name = "Awesome",
    urgency = 'normal'
}
-- }}}
