-- ===================================================================
-- Initialization
-- ===================================================================
local awful     = require("awful")
local ruled     = require("ruled")
local mywidgets = require("helpers.mywidgets")

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function(c)
    -- All clients will match this rule.
    local geo = awful.screen.focused().geometry
    ruled.client.append_rule {
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            -- shape = mywidgets.shape,
            placement = awful.placement.no_overlap +
                awful.placement.no_offscreen,
            titlebars_enabled = false
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id = "floating",
        rule_any = {
            instance = {},
            type = { "dialog", "Dialog" },
            class = { "Blueman-manager", "YesPlayMusic" },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = { "OSD", "Preferences", "FeynArts Topology Editor" },
            role = {
                "AlarmWindow", -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true, placement = awful.placement.centered }
    }

    ruled.client.append_rule {
        id = "screen capture",
        rule = { class = "feh", name = "stdin" },
        properties = {
            floating = true,
            placement = awful.placement.under_mouse,
            skip_taskbar = true,
            ontop = true
        }
    }

    ruled.client.append_rule {
        id = "navigator",
        rule_any = { class = { "Navigator", "librewolf" } },
        properties = {
            titlebars_enabled = false,
            placement = awful.placement.centered
            -- width = math.ceil(geo.width / 3),
            -- height = math.ceil(geo.height / 8)
        }
        -- callback = function( c )
        --   c:geometry( { width = math.ceil(geo.width/3) , height = math.ceil(geo.height/8) } )
        --            end
    }

    -- can be memory comsume
    -- TODO change following to properties and change by connect signal
    local fx, fy, fwidth, fheight = mywidgets.geometry(0.5, "bottom_left")

    ruled.client.append_rule {
        id = "Play video in float window",
        rule_any = { name = { "Picture-in-Picture", "Picture in picture" } },
        properties = {
            floating = true,
            placement = awful.placement.bottom_right,
            skip_taskbar = true,
            sticky = true,
            x = fx,
            y = fy,
            width = fwidth,
            height = fheight,
            opacity = 0.85,
            shape = mywidgets.shape,
            ontop = true
        }
    }
    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- ruled.client.append_rule {
    --     rule       = { class = "Firefox"     },
    --     properties = { screen = 1, tag = "2" }
    -- }
end)

-- }}}