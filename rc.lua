--     ___        _______ ____   ___  __  __ _____
--    / \ \      / / ____/ ___| / _ \|  \/  | ____|
--   / _ \ \ /\ / /|  _| \___ \| | | | |\/| |  _|
--  / ___ \ V  V / | |___ ___) | |_| | |  | | |___
-- /_/   \_\_/\_/  |_____|____/ \___/|_|  |_|_____|
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

SCRIPTS_DIR = gears.filesystem.get_configuration_dir() .. "scripts/"

-- {{{ Autostart
awful.spawn.with_shell(SCRIPTS_DIR .. "autostart.sh")
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "/themes/default.lua")
-- Wallpaper at awesome start
awful.spawn.with_shell(SCRIPTS_DIR .. "wallpaper.sh -r")
-- for s = 1, screen.count() do
--     gears.wallpaper.maximized(beautiful.wallpaper, s, true)
-- end

local function gio_launch(desktop)
    return string.format("gio launch %s/.local/share/applications/%s.desktop", os.getenv("HOME"), desktop)
end

-- define default apps (global variable so other modules can access it)
APPS = {
    terminal = gio_launch("vterm"),
    editor = os.getenv("VISUAL") or os.getenv("EDITOR"),
    emacs_everywhere = "emacsclient -s utility --eval \"(emacs-everywhere)\"",
    launcher = "rofi -show combi",
    browser = "librewolf",
    filebrowser = gio_launch("dirvish"),
    theme_selector = SCRIPTS_DIR .. "theme-selector.sh",
    lock_screen = SCRIPTS_DIR .. "screensaver.sh lock"
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
require("modules.topbar")
-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
require("modules.rules")
-- }}}

-- {{{ Notifications
require("modules.notifications")

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule = {},
        properties = { screen = awful.screen.preferred, implicit_timeout = 5 }
    }
end)

CUR_THEME = "default"
local wal_file = io.open(os.getenv("HOME") .. "/.cache/wal/current_theme", "rb")
if wal_file ~= nil then
    CUR_THEME = wal_file:read "a"
    CUR_THEME = CUR_THEME:match(".*/([^/]+/[^/]+)$") or CUR_THEME
end

naughty.notification {
    title = 'Welcome',
    message = string.format('Awesome WM is started\n<b>Colors</b>: <u>%s</u>', CUR_THEME),
    app_icon = "Diana-Circle",
    app_name = "Awesome",
    urgency = 'normal'
}
-- }}}

-- {{{ Key and Mouse bindings
local keys = require("modules.keys")
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

require("modules.exit-screen")
-- }}}

require("modules.screen-shot")
