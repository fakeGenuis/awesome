-- ===================================================================
-- Initialization
-- ===================================================================
local awful = require("awful")
local ruled = require("ruled")

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap +
                awful.placement.no_offscreen
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id = "floating",
        rule_any = {
            instance = {},
            type = {"dialog", "Dialog"},
            class = {"Blueman-manager", "YesPlayMusic"},
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {"OSD", "Preferences", "FeynArts Topology Editor"},
            role = {
                "AlarmWindow", -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {floating = true, placement = awful.placement.centered}
    }

    ruled.client.append_rule {
        id = "screen capture",
        rule = {class = "feh", name = "stdin"
        },
        properties = {
            floating = true,
            placement = awful.placement.under_mouse,
            ontop = true
        }
    }

    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule {
        id = "titlebars",
        rule_any = {type = {"normal"}},
        properties = {titlebars_enabled = false}
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- ruled.client.append_rule {
    --     rule       = { class = "Firefox"     },
    --     properties = { screen = 1, tag = "2" }
    -- }
end)

-- }}}

