--   _____    ___    ____    ____       _      ____
--  |_   _|  / _ \  |  _ \  | __ )     / \    |  _ \
--    | |   | | | | | |_) | |  _ \    / _ \   | |_) |
--    | |   | |_| | |  __/  | |_) |  / ___ \  |  _ <
--    |_|    \___/  |_|     |____/  /_/   \_\ |_| \_\
-- ===================================================================
-- Initialization
-- ===================================================================
-- Widget and layout library
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local lain = require("lain")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local mywidgets = require("mywidgets")

-- {{{ Wibar
--

-- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
local mytextclock = mywidgets.block {
    refresh = 1,
    format = "%H:%M:%S",
    widget = wibox.widget.textclock
}

-- Network info
local net_up = wibox.widget.textbox();
local net_down = wibox.widget.textbox();

-- update textbox markup
lain.widget.net {
    wifi_state = "on",
    eth_state = "on",
    settings = function()
        net_up:set_markup(mywidgets.KMG(net_now.sent))
        net_down:set_markup(mywidgets.KMG(net_now.received))
    end
}

-- system info widget
local myinfoblock = mywidgets.block {

    -- network
    mywidgets.icon_text("󰁆"),
    net_down,
    -- mywidgets.icon_text("󰁞"),
    -- net_up,

    -- package upgradable
    mywidgets.icon_text("󰚰"),
    awful.widget.watch(
        'bash -c "pamac checkupdates | grep -E [0-9\\.]- | wc -l"', 3600),

    -- volume
    lain.widget.alsa {
        settings = function()
            if volume_now.status == 'off' then
                widget:set_markup("󰝟")
            else
                local vl = tonumber(volume_now.level)
                if vl == 0 then
                    widget:set_markup("󰖁")
                elseif vl < 33 then
                    widget:set_markup("󰕿")
                elseif vl < 66 then
                    widget:set_markup("󰖀")
                else
                    widget:set_markup("󰕾")
                end
            end
        end
    },
    lain.widget.alsa {
        settings = function()
            local vl = tonumber(volume_now.level)
            if volume_now.status ~= 'on' or vl == 0 then
                widget:set_markup("")
            else
                widget:set_markup(volume_now.level)
            end
        end
    },

    -- cpu usage
    mywidgets.icon_text("󰻠"),
    lain.widget.cpu {settings = function() widget:set_markup(cpu_now.usage) end},

    -- mem usage
    mywidgets.icon_text("󰍛"),
    lain.widget.mem {
        settings = function()
            widget:set_markup(string.format("%.0f", mem_now.perc))
        end
    },

    -- lain.widget.temp({
    --     settings = function() widget:set_markup("󰈸" .. coretemp_now) end
    -- }),
    layout = wibox.layout.fixed.horizontal
}

screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    local names = {"󱁖", "󱃠", "󰅪", "󰭹", "󰒓", "󰑴", "󰊗"}
    local l = awful.layout.suit
    local layouts = {
        l.max, l.max, l.tile, l.floating, l.max, l.tile, l.floating
    }
    awful.tag(names, s, layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = mywidgets.block {
        {
            format = "%H:%M",
            forced_height = dpi(19),
            forced_width = dpi(19),
            widget = awful.widget.layoutbox
        },
        top = dpi(2),
        bottom = dpi(2),
        widget = wibox.container.margin
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
        widget_template = mywidgets.wibox_cb(mywidgets.block {
            id = "text_role",
            align = "center",
            valign = "center",
            font = beautiful.iconfont,
            widget = wibox.widget.textbox
        }),
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 3, awful.tag.viewtoggle),
            -- awful.button({modkey}, 1, function(t)
            --     if client.focus then client.focus:move_to_tag(t) end
            -- end),
            -- awful.button({modkey}, 3, function(t)
            --     if client.focus then client.focus:toggle_tag(t) end
            -- end),
            awful.button({}, 4, function(t)
                awful.tag.viewprev(t.screen)
            end),
            awful.button({}, 5, function(t)
                awful.tag.viewnext(t.screen)
            end)
        }
    }

    -- Create a tasklist icon only widget
    s.mytasklist_icons = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        widget_template = mywidgets.wibox_cb {
            mywidgets.block {
                {awful.widget.clienticon, widget = wibox.container.margin},
                {
                    mywidgets.icon_text('󰅙'),
                    right = dpi(1),
                    left = dpi(1),
                    -- id = "background_role",
                    widget = wibox.container.margin
                },
                layout = wibox.layout.align.horizontal
            },
            widget = wibox.container.place
        },
        buttons = {
            awful.button({}, 1, function(c)
                if c == client.focus then
                    c.minimized = true
                else
                    -- Without this, the following
                    -- :isvisible() makes no sense
                    c.minimized = false
                    if not c:isvisible() and c.first_tag then
                        c.first_tag:view_only()
                    end
                    -- This will also un-minimize
                    -- the client, if needed
                    c:emit_signal('request::activate')
                    c:raise()
                end
            end),
            awful.button({}, 4, function()
                awful.client.focus.byidx(-1)
            end),
            awful.button({}, 5, function()
                awful.client.focus.byidx(1)
            end)
        }
    }

    -- Create a tasklist widget
    s.mytask_title = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.focused,
        widget_template = mywidgets.wibox_cb {
            mywidgets.block {
                id = "text_role",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox
            },
            widget = wibox.container.place,
            fill_horizontal = false,
            fill_vertical = true
        },

        buttons = {
            awful.button({}, 1, function(c)
                c:activate{context = "tasklist", action = "toggle_minimization"}
            end)
            -- awful.button({}, 3, function()
            --     awful.menu.client_list {theme = {width = 270}}
            -- end),
        }
    }

    -- systray widget
    s.mysystray = mywidgets.block({

        {
            screen = s or screen.primary,
            base_size = dpi(23),
            horizontal = true,
            opacity = 0,
            widget = wibox.widget.systray
        },
        left = dpi(4),
        right = dpi(4),
        widget = wibox.container.margin
    }, {bg = beautiful.bg_minimize})

    -- Create the wibox
    s.mywibox = awful.wibar({
        type = 'dock',
        position = "top",
        height = dpi(23),
        width = s.geometry.width - dpi(4),
        margins = {top = dpi(2), bottom = dpi(0)},
        opacity = 1,
        screen = s
    })

    -- s.mywibox:struts{top = dpi(25)}

    -- Add widgets to the wibox
    s.mywibox:setup{
        {
            layout = wibox.layout.align.horizontal,
            -- expand = 'none',
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(3),
                s.mytaglist,
                s.mytasklist_icons,
                s.mypromptbox
            },
            s.mytask_title, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(3),
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
