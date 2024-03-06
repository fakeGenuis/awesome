--   _____    ___    ____    ____       _      ____
--  |_   _|  / _ \  |  _ \  | __ )     / \    |  _ \
--    | |   | | | | | |_) | |  _ \    / _ \   | |_) |
--    | |   | |_| | |  __/  | |_) |  / ___ \  |  _ <
--    |_|    \___/  |_|     |____/  /_/   \_\ |_| \_\
-- ===================================================================
-- Initialization
-- ===================================================================
-- Widget and layout library
local wibox       = require("wibox")
local awful       = require("awful")
local lain        = require("lain")
local beautiful   = require("beautiful")
local bluetooth   = require("widgets.bluetooth")
local dpi         = beautiful.xresources.apply_dpi
local mywidgets   = require("helpers.mywidgets")
local markup      = lain.util.markup
local pipewire    = require("widgets.pipewire")

-- {{{ Wibar
--

-- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
local mytextclock = mywidgets.block {
    refresh = 1,
    font = beautiful.mono_font,
    format = "%H:%M:%S",
    widget = wibox.widget.textclock
}

-- extra netdown textbox
local mynetdown   = wibox.widget.textbox()

-- update netdown markup
-- see https://github.com/lcpz/lain/wiki/net#usage-examples
-- and https://github.com/lcpz/lain/issues/464
lain.widget.net {
    wifi_state = "on",
    eth_state = "on",
    settings = function()
        local rec = net_now.received
        local color = mywidgets.usage_color(rec, 1024 * 60, 4)
        mynetdown:set_markup(markup.fontfg(beautiful.icon_font, color,
            "󰇚" .. mywidgets.KMG(rec)))
    end
}

-- system info widget
local myinfoblock = mywidgets.block({
    -- Bluetooth device battery (if pluged in)
    bluetooth {
        settings = function()
            local color = mywidgets.usage_color(100 - battery_now.battery)
            widget:set_markup(markup.fontfg(beautiful.icon_font, color,
                battery_now.icon))
        end
    },

    -- Network info
    mynetdown,

    -- Package upgradable
    awful.widget.watch(
        beautiful.updates_command, 600,
        function(widget, stdout)
            local color = mywidgets.usage_color(stdout)
            widget:set_markup(markup.fontfg(beautiful.icon_font, color,
                "󰚰" .. stdout))
        end),

    -- cpu usage
    lain.widget.cpu {
        settings = function()
            local usage = cpu_now.usage
            local color = mywidgets.usage_color(usage)
            widget:set_markup(markup.fontfg(beautiful.icon_font, color,
                "󰻠" .. usage))
        end
    },

    -- CPU package temperature
    awful.widget.watch(
        beautiful.temp_command, 3,
        function(widget, stdout)
            local color = mywidgets.usage_color(stdout)
            widget:set_markup(markup.fontfg(beautiful.icon_font, color,
                "󰔏" .. stdout))
        end),

    -- mem usage
    lain.widget.mem {
        settings = function()
            local perc = mem_now.perc
            local color = mywidgets.usage_color(perc)
            widget:set_markup(markup.fontfg(beautiful.icon_font, color, "󰍛" ..
                string.format("%.0f", perc)))
        end
    },

    -- volume
    pipewire {
        settings = function()
            local vl = volume_now.left or 0
            local color = mywidgets.usage_color(vl)
            widget:set_markup(markup.fontfg(beautiful.icon_font, color, icon(vl) .. vl))
        end
    },

    -- lain.widget.temp({
    --     settings = function() widget:set_markup("󰈸" .. coretemp_now) end
    -- }),
    layout = wibox.layout.fixed.horizontal
}, { bg = beautiful.fg_normal })

screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    local names = { "1", "2", "3", "4"}
    local l = awful.layout.suit
    local layouts = l.floating
    -- local layouts = {
    --     l.max, l.max, l.tile, l.floating, l.max, l.tile, l.floating
    -- }
    awful.tag(names, s, layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = mywidgets.block {
        {
            format = "%H:%M",
            forced_height = beautiful.topbar_height - beautiful.margin_spacing,
            forced_width = beautiful.topbar_height - beautiful.margin_spacing,
            widget = awful.widget.layoutbox
        },
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place
    }
    s.mylayoutbox.buttons = {
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(-1) end),
        awful.button({}, 5, function() awful.layout.inc(1) end)
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.noempty,
        widget_template = mywidgets.wibox_cb(mywidgets.block(
            mywidgets.textbox {
                id = "text_role"
            }, { forced_width = beautiful.topbar_height })),
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 1, function(t)
                if client.focus then client.focus:move_to_tag(t) end
            end), awful.button({ modkey }, 3, function(t)
            if client.focus then client.focus:toggle_tag(t) end
        end),
            awful.button({}, 4, function(t)
                awful.tag.viewprev(t.screen)
            end),
            awful.button({}, 5, function(t)
                awful.tag.viewnext(t.screen)
            end)
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        layout = wibox.widget {
            spacing = beautiful.spacing,
            layout = wibox.layout.ratio.horizontal
        },
        widget_template = mywidgets.wibox_cb {
            awful.widget.clienticon,
            mywidgets.block(mywidgets.textbox {
                id = "text_role",
                font = beautiful.font
            }),
            spacing = beautiful.spacing,
            layout = wibox.layout.fixed.horizontal
        },

        buttons = {
            awful.button({}, 1, function(c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end), awful.button({}, 3, function()
            awful.menu.client_list { theme = { width = 270 } }
        end)
        }
    }

    -- systray widget
    s.mysystray = mywidgets.block({
        {
            screen = s or screen.primary,
            base_size = beautiful.topbar_height,
            horizontal = true,
            opacity = 0,
            widget = wibox.widget.systray
        },
        -- to hide rectangle systray corner
        left = dpi(4),
        right = dpi(4),
        widget = wibox.container.margin
    }, {
        -- cover the unsetable wibox.widget.systray bg
        bg = beautiful.bg_minimize
    })

    -- Create the wibox
    s.mywibox = awful.wibar {
        type     = 'dock',
        position = "top",
        height   = beautiful.topbar_height,
        -- width   = s.geometry.width - 2 * beautiful.spacing,
        margins  = {
            top    = beautiful.spacing,
            bottom = 0,
            left   = beautiful.spacing,
            right  = beautiful.spacing
        },
        screen   = s
    }

    s.mywibox:struts { top = beautiful.topbar_height + beautiful.spacing }

    -- Add widgets to the wibox
    s.mywibox:setup {
        {
            layout = wibox.layout.align.horizontal,
            expand = 'inside',
            {
                -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = beautiful.spacing,
                s.mytaglist,
                s.mytasklist_icons,
                s.mypromptbox
            },
            {
                -- Middle widget
                {
                    left = beautiful.spacing,
                    right = beautiful.spacing,
                    s.mytasklist,
                    widget = wibox.container.margin
                },
                widget = wibox.container.place
            },
            {
                -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = beautiful.spacing,
                mytextclock,
                myinfoblock,
                s.mysystray,
                s.mylayoutbox
            }
        },
        widget = wibox.container.background
    }
end)
-- }}}
