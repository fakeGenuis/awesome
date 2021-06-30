-- ===================================================================
-- Initialization
-- ===================================================================
-- Widget and layout library
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local lain = require("lain")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local mywidgets = require("mywidgets")

-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
local mytextclock = wibox.widget(mywidgets.text_in({
    format = "%H:%M",
    widget = wibox.widget.textclock
}))

local myinfoblock = wibox.widget(mywidgets.text_in({
    lain.widget.net({
        settings = function()
            widget:set_font(beautiful.iconfont)
            widget:set_markup("󰁆" .. mywidgets.KMG(net_now.received) ..
                                  "󰁞" .. mywidgets.KMG(net_now.sent))
        end
    }),
    lain.widget.alsa({
        settings = function()
            widget:set_font(beautiful.iconfont)
            if volume_now.status == 'off' then
                widget:set_markup("󰝟")
            else
                local vl = tonumber(volume_now.level)
                if vl == 0 then
                    widget:set_markup("󰖁")
                elseif vl < 33 then
                    widget:set_markup("󰕿" .. volume_now.level)
                elseif vl < 66 then
                    widget:set_markup("󰖀" .. volume_now.level)
                else
                    widget:set_markup("󰕾" .. volume_now.level)
                end
            end
        end
    }),
    lain.widget.cpu({
        settings = function()
            widget:set_markup("󰻠" .. cpu_now.usage)
            widget:set_font(beautiful.iconfont)
        end
    }),
    lain.widget.mem({
        settings = function()
            widget:set_font(beautiful.iconfont)
            widget:set_markup("󰍛" .. string.format("%.0f", mem_now.perc))
        end
    }),
    -- lain.widget.temp({
    --     settings = function() widget:set_markup("󰈸" .. coretemp_now) end
    -- }),
    layout = wibox.layout.fixed.horizontal
}))

screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    local names = {"󰈹", "󰆍", "󰅪", "󰒓", "󰎆", "󰑴", "󰊗"}
    local l = awful.layout.suit
    local layouts = {
        l.max, l.tile, l.spiral, l.floating, l.floating, l.tile, l.floating
    }
    awful.tag(names, s, layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = wibox.widget {
        screen = s,
        buttons = {
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc(-1) end),
            awful.button({}, 5, function() awful.layout.inc(1) end)
        },
        {
            {
                format = "%H:%M",
                forced_height = dpi(19),
                forced_width = dpi(19),
                widget = awful.widget.layoutbox
            },
            top = dpi(4),
            bottom = dpi(4),
            right = dpi(4),
            left = dpi(4),
            widget = wibox.container.margin
        },

        bg = '#C9DDFCff',
        border_width = dpi(2),
        border_color = "#ffffff00",
        shape = function(c, w, h)
            gears.shape.rounded_rect(c, w, h, dpi(7))
        end,
        widget = wibox.container.background
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.noempty,
        style = {font = "Material Design Icons 16"},
        layout = {layout = wibox.layout.fixed.horizontal},
        widget_template = mywidgets.text_in({
            id = "text_role",
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox
        }),
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({modkey}, 1, function(t)
                if client.focus then client.focus:move_to_tag(t) end
            end), awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({modkey}, 3, function(t)
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
        style = {layout = wibox.layout.fixed.horizontal, spacing = dpi(5)},
        widget_template = {
            {
                {
                    {awful.widget.clienticon, widget = wibox.container.margin},
                    mywidgets.text_in({
                        id = "text_role",
                        align = "center",
                        valign = "center",
                        widget = wibox.widget.textbox
                    }),
                    layout = wibox.layout.fixed.horizontal
                },
                widget = wibox.container.background,
                id = "background_role"
            },
            widget = wibox.container.place,
            fill_horizontal = false
        },
        buttons = {
            awful.button({}, 1, function(c)
                c:activate{context = "tasklist", action = "toggle_minimization"}
            end), awful.button({}, 3, function()
                awful.menu.client_list {theme = {width = 270}}
            end),
            awful.button({}, 4, function()
                awful.client.focus.byidx(-1)
            end),
            awful.button({}, 5, function()
                awful.client.focus.byidx(1)
            end)
        }
    }

    s.mysystray = wibox.widget {

        {
            {
                screen = s or screen.primary,
                base_size = dpi(23),
                -- horizontal = true,
                opacity = 0.01,
                widget = wibox.widget.systray
            },
            top = dpi(2),
            bottom = dpi(2),
            right = dpi(9),
            left = dpi(9),
            opacity = 0,
            color = '#C9DDFC00',
            widget = wibox.container.margin
        },

        bg = '#C9DDFCff',
        border_width = dpi(2),
        border_color = "#ffffff00",
        shape = function(c, w, h)
            gears.shape.rounded_rect(c, w, h, dpi(7))
        end,
        widget = wibox.container.background
    }

    -- Create the wibox
    s.mywibox = awful.wibar({
        type = 'dock',
        position = "top",
        height = dpi(27),
        width = s.geometry.width,
        opacity = 1,
        screen = s
    })

    s.mywibox:struts{top = dpi(27)}

    -- Add widgets to the wibox
    s.mywibox:setup{
        {
            layout = wibox.layout.align.horizontal,
            -- expand = 'none',
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                s.mypromptbox
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                -- mykeyboardlayout,
                mytextclock,
                myinfoblock,
                s.mysystray,
                s.mylayoutbox
            }
        },
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }
end)
-- }}}
