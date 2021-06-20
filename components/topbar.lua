-- ===================================================================
-- Initialization
-- ===================================================================
-- Widget and layout library
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
local mytextclock = wibox.widget {
    {
        {format = "%H:%M", widget = wibox.widget.textclock},
        right = dpi(4),
        left = dpi(4),
        widget = wibox.container.margin
    },

    bg = '#C9DDFCff',
    border_width = dpi(2),
    border_color = "#ffffff00",
    shape = function(c, w, h) gears.shape.rounded_rect(c, w, h, dpi(7)) end,
    widget = wibox.widget.background
}

screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    local names = {"󰈹", "󰒓", "󰎆", "󰆍", "󰅪", "󰑴", "󰊗"}
    local l = awful.layout.suit
    local layouts = {l.max, l.max, l.floating, l.max, l.max, l.floating}
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
        widget = wibox.widget.background
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.noempty,
        style = {font = "Material Design Icons 16"},
        layout = {
            -- spacing = dpi(0),
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                id = "text_role",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox
            },
            bg = '#C9DDFCff',
            shape = function(c, w, h)
                gears.shape.rounded_rect(c, w, h, dpi(7))
            end,
            border_width = dpi(2),
            border_color = "#ffffff00",
            forced_height = dpi(27),
            forced_width = dpi(27),
            widget = wibox.container.background
        },
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
                    {
                        {
                            {
                                id = "text_role",
                                align = "center",
                                valign = "center",
                                widget = wibox.widget.textbox
                            },
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
                        widget = wibox.widget.background
                    },
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
        widget = wibox.widget.background
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
                spacing = dpi(5),
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                s.mypromptbox
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                spacing = dpi(5),
                layout = wibox.layout.fixed.horizontal,
                -- mykeyboardlayout,
                s.mysystray,
                mytextclock,
                s.mylayoutbox
            }
        },
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }
end)
-- }}}
