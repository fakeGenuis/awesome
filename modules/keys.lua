-- ===================================================================
-- Initialization
-- ===================================================================
local awful         = require("awful")
local gears         = require("gears")
local naughty       = require("naughty")
local beautiful     = require("beautiful")
local dpi           = beautiful.xresources.apply_dpi
-- hotkeys pop up
local hotkeys_popup = require("awful.hotkeys_popup.widget")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
local pop_keys      = require("awful.hotkeys_popup.keys")

-- Define mod keys
local modkey = "Mod4"
local altkey = "Mod1"
pop_keys.tmux.add_rules_for_terminal({
    rule_any = { name = { "tmux" }, instance = { "tmux" } }
})

-- define module table
local keys = {}

-- ===================================================================
-- Movement Functions (Called by some keybinds)
-- ===================================================================

-- Move given client to given direction
local function move_client(c, direction)
    -- If client is floating, move to edge
    if c.floating or
        (awful.layout.get(mouse.screen) == awful.layout.suit.floating) then
        local workarea = awful.screen.focused().workarea
        if direction == "up" then
            c:geometry({
                nil,
                y = workarea.y + beautiful.useless_gap * 2,
                nil,
                nil
            })
        elseif direction == "down" then
            c:geometry({
                nil,
                y = workarea.height + workarea.y - c:geometry().height -
                    beautiful.useless_gap * 2 - beautiful.border_width * 2,
                nil,
                nil
            })
        elseif direction == "left" then
            c:geometry({
                x = workarea.x + beautiful.useless_gap * 2,
                nil,
                nil,
                nil
            })
        elseif direction == "right" then
            c:geometry({
                x = workarea.width + workarea.x - c:geometry().width -
                    beautiful.useless_gap * 2 - beautiful.border_width * 2,
                nil,
                nil,
                nil
            })
        end
        -- Otherwise swap the client in the tiled layout
    elseif awful.layout.get(mouse.screen) == awful.layout.suit.max then
        if direction == "up" or direction == "left" then
            awful.client.swap.byidx(-1, c)
        elseif direction == "down" or direction == "right" then
            awful.client.swap.byidx(1, c)
        end
    else
        awful.client.swap.bydirection(direction, c, nil)
    end
end

-- Resize client in given direction
local floating_resize_amount = dpi(20)
local tiling_resize_factor = 0.03

local function resize_client(c, direction)
    if awful.layout.get(mouse.screen) == awful.layout.suit.floating or
        (c and c.floating) then
        if direction == "up" then
            c:relative_move(0, 0, 0, -floating_resize_amount)
        elseif direction == "down" then
            c:relative_move(0, 0, 0, floating_resize_amount)
        elseif direction == "left" then
            c:relative_move(0, 0, -floating_resize_amount, 0)
        elseif direction == "right" then
            c:relative_move(0, 0, floating_resize_amount, 0)
        end
    else
        if direction == "up" then
            awful.client.incwfact(-tiling_resize_factor)
        elseif direction == "down" then
            awful.client.incwfact(tiling_resize_factor)
        elseif direction == "left" then
            awful.tag.incmwfact(-tiling_resize_factor)
        elseif direction == "right" then
            awful.tag.incmwfact(tiling_resize_factor)
        end
    end
end

-- raise focused client
local function raise_client() if client.focus then client.focus:raise() end end

-- ===================================================================
-- Mouse bindings
-- ===================================================================

-- Mouse buttons on the desktop
keys.desktopbuttons = gears.table
    .join(-- left click on desktop to hide notification
        awful.button({}, 1, function() naughty.destroy_all_notifications() end)-- awful.button({ }, 4, awful.tag.viewprev),
    -- awful.button({ }, 5, awful.tag.viewnext)
    )

-- Mouse buttons on the client
keys.clientmouse = gears.table.join(awful.button({}, 1, function(c)
    c:activate { context = "mouse_click" }
end), awful.button({ modkey }, 1, function(c)
    c:activate { context = "mouse_click", action = "mouse_move" }
end), awful.button({ modkey }, 3, function(c)
    c:activate { context = "mouse_click", action = "mouse_resize" }
end))

-- ===================================================================
-- Desktop Key bindings
-- ===================================================================

keys.globalkeys = gears.table.join(-- =========================================
-- SPAWN APPLICATION KEY BINDINGS
-- =========================================
-- Spawn terminal
    awful.key({ modkey }, "Return", function() awful.spawn(APPS.terminal) end,
        { description = "open a terminal", group = "launcher" }),
    -- launch rofi
    awful.key({ modkey }, "a", function() awful.spawn(APPS.launcher) end,
        { description = "open application launcher", group = "launcher" }),
    awful.key({ modkey }, "e", function() awful.spawn(APPS.editor) end,
        { description = "open editor", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "e",
        function() awful.spawn(APPS.emacs_everywhere) end,
        { description = "edit in emacs", group = "launcher" }),
    awful.key({ modkey }, "r", function() awful.spawn(APPS.filebrowser) end,
        { description = "open file browser", group = "launcher" }),
    awful.key({ modkey }, "b", function() awful.spawn(APPS.browser) end,
        { description = "open browser", group = "launcher" }),
    awful.key({ modkey }, "s", function() awful.spawn(APPS.theme_selector) end,
        { description = "switch color themes from <u>wal</u>", group = "awesome" }),
    awful.key({ modkey}, "c",
        function() if client.focus then awful.placement.centered(client.focus) end end,
        { description = "center current windows", group = "awesome" }),
    --   awful.key({ modkey }, "p",
    --      function()
    --         menubar.show()
    --      end,
    --      {description = "show the menubar", group = "awesome"}
    --   ),
    awful.key({ modkey }, "F1", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    -- awful.key({modkey, "Ctrl"}, "q", awesome.quit,
    --           {description = "quit awesome", group = "awesome"}),
    -- awful.key({modkey, "Ctrl"}, "l", function() awful.spawn(apps.lock) end,
    --           {description = "lock screen", group = "awesome"}),
    -- awful.key({modkey}, "F4", function()
    --    awful.prompt.run({prompt = "Run Lua code: "},
    --    mypromptbox[mouse.screen].widget,
    --    awful.util.eval, nil,
    --    awful.util.getdir("cache") .. "/history_eval")
    --    end)
    -- )

    -- =========================================
    -- FUNCTION KEYS
    -- =========================================

    -- Brightness
    awful.key({}, "XF86MonBrightnessUp",
        function() awful.spawn("xbacklight -inc 10", false) end,
        { description = "+10%", group = "awesome" }),
    awful.key({}, "XF86MonBrightnessDown",
        function() awful.spawn("xbacklight -dec 10", false) end,
        { description = "-10%", group = "awesome" }),
    -- Pipewire-pulsa volume control
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +3%", false)
        awesome.emit_signal("volume_change")
    end, { description = "volume up", group = "awesome" }),
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -3%", false)
        awesome.emit_signal("volume_change")
    end, { description = "volume down", group = "awesome" }),
    awful.key({}, "XF86AudioMute", function()
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
        awesome.emit_signal("volume_change")
    end, { description = "toggle mute", group = "awesome" }),
    awful.key({}, "XF86AudioNext",
        function() awful.spawn("playerctl next", false) end,
        { description = "next music", group = "awesome" }),
    awful.key({}, "XF86AudioPrev",
        function() awful.spawn("playerctl previous", false) end,
        { description = "previous music", group = "awesome" }),
    awful.key({}, "XF86AudioPlay",
        function() awful.spawn("playerctl play-pause", false) end,
        { description = "play/pause music", group = "awesome" }),

    awful.key({}, "Print", function()
        -- awful.spawn(apps.screenshot, false)
        awesome.emit_signal('module::screenshot:show')
    end, { description = "screenshot", group = "awesome" }),

    -- =========================================
    -- RELOAD / QUIT AWESOME
    -- =========================================

    -- Reload Awesome
    -- awful.key({modkey, "Ctrl"}, "r", awesome.restart,
    --           {description = "reload awesome", group = "awesome"}), -- Quit Awesome
    awful.key({ modkey, "Shift" }, "q", function()
        -- emit signal to show the exit screen
        awesome.emit_signal("module::exit_screen:show")
    end, { description = "show exit screen", group = "awesome" }),

    awful.key({ modkey }, "i", function()
        -- emit signal to show the exit screen
        awesome.emit_signal("module::notification:toggle")
    end, { description = "toggle notification bar", group = "awesome" }),
    -- awful.key({}, "XF86PowerOff",
    --    function()
    --       -- emit signal to show the exit screen
    --       awesome.emit_signal("show_exit_screen")
    --    end,
    --    {description = "toggle exit screen", group = "hotkeys"}
    -- ),

    -- =========================================
    -- SCREEN FOCUSING
    -- =========================================

    -- Focus screen by index (cycle through screens)
    -- awful.key({modkey}, "s",
    --    function()
    --       awful.screen.focus_relative(1)
    --    end
    -- ),

    -- =========================================
    -- GAP CONTROL
    -- =========================================

    -- Gap control
    awful.key({ modkey, "Shift" }, "minus", function() awful.tag.incgap(5, nil) end, {
        description = "increment gaps size for the current tag",
        group = "layout"
    }), awful.key({ modkey }, "minus", function() awful.tag.incgap(-5, nil) end, {
        description = "decrement gap size for the current tag",
        group = "layout"
    }), -- =========================================
    -- LAYOUT SELECTION
    -- =========================================
    -- select next layout
    awful.key({ modkey }, "\\", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    -- select previous layout
    awful.key({ modkey, "Shift" }, "\\", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),

    -- =========================================
    -- DYNAMIC TAGGING
    -- =========================================
    -- awful.key({ modkey, "Shift" }, "a", function () lain.util.add_tag() end,
    --           {description = "add new tag", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end,
    --           {description = "rename tag", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end,
    --           {description = "move tag to the left", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end,
    --           {description = "move tag to the right", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end,
    --           {description = "delete tag", group = "tag"}),

    -- =========================================
    -- SELECT TAG
    -- =========================================
    awful.key({ modkey }, "h", function(s) awful.tag.viewprev(s) end,
        { description = "focus previous tag by index", group = "tag" }),
    awful.key({ modkey }, "l", function(s) awful.tag.viewnext(s) end,
        { description = "focus next tag by index", group = "tag" }),
    awful.key({ modkey }, "=", function()
        local tags = awful.screen.focused().tags
        local tag_name = string.format('%d', #tags + 1)
        awful.tag.add(tag_name, {
            screen = awful.screen.focused(),
            layout = awful.layout.suit.floating
        }):view_only()
    end, { description = "add new tag", group = "tag" }),
    awful.key({ modkey, "Shift" }, "=", function()
        local t = awful.screen.focused().selected_tag
        if not t then return end
        t:delete()
    end, { description = "delete current tag", group = "tag" }),
    awful.key {
        modifiers = { modkey },
        keygroup = "numrow",
        description = "only view tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then tag:view_only() end
        end
    }, awful.key {
        modifiers = { modkey, "Control" },
        keygroup = "numrow",
        description = "toggle tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then awful.tag.viewtoggle(tag) end
        end
    }, awful.key {
        modifiers = { modkey, "Shift" },
        keygroup = "numrow",
        description = "move focused client to tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then client.focus:move_to_tag(tag) end
            end
        end
    }, awful.key {
        modifiers = { modkey, "Control", "Shift" },
        keygroup = "numrow",
        description = "toggle focused client on tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then client.focus:toggle_tag(tag) end
            end
        end
    })

-- ===================================================================
-- Client Key bindings
-- ===================================================================

keys.clientkeys = gears.table.join(-- Focus client by direction (jk keys)
    awful.key({ modkey }, "j", function()
        awful.client.focus.byidx(1)
        raise_client()
    end, { description = "focus next by index", group = "client" }),
    awful.key({ modkey }, "k", function()
        awful.client.focus.byidx(-1)
        raise_client()
    end, { description = "focus previous by index", group = "client" }),
    awful.key({ modkey }, "f", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey }, "t",
        function() client.focus.ontop = not client.focus.ontop end,
        { description = "toggle ontop", group = "client" }),
    -- restore minimized client
    awful.key({ modkey, "Shift" }, "n", function()
        -- for _, cl in ipairs(mouse.screen.selected_tag:clients()) do
        --     if cl.minimized then
        --         cl.minimized = false
        --         client.focus = cl
        --         cl:raise()
        --         break
        --     end
        -- end
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal("request::activate", "key.unminimize", { raise = true })
            -- client.focus = c
            -- c:raise()
        end
    end, { description = "restore minimized", group = "client" }),
    -- Move to edge or swap by direction
    awful.key({ modkey, "Shift" }, "j", function(c) move_client(c, "down") end,
        { description = "move up", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function(c) move_client(c, "up") end,
        { description = "move down", group = "client" }),
    awful.key({ modkey, "Shift" }, "h", function(c) move_client(c, "left") end,
        { description = "move left", group = "client" }),
    awful.key({ modkey, "Shift" }, "l", function(c) move_client(c, "right") end,
        { description = "move right", group = "client" }), -- toggle fullscreen
    awful.key({ modkey }, "F11", function(c) c.fullscreen = not c.fullscreen end,
        { description = "toggle fullscreen", group = "client" }),
    -- close client
    awful.key({ modkey }, "q", function(c) c:kill() end,
        { description = "close", group = "client" }), -- Minimize
    awful.key({ modkey }, "n", function(c) c.minimized = true end,
        { description = "minimize", group = "client" }), -- Maximize
    awful.key({ modkey }, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
    end, { description = "(un)maximize", group = "client" }), -- client resizing
    awful.key({ modkey, "Control" }, "j",
        function(_) resize_client(client.focus, "up") end,
        { description = "resize up", group = "client" }),
    awful.key({ modkey, "Control" }, "k",
        function(_) resize_client(client.focus, "down") end,
        { description = "resize down", group = "client" }),
    awful.key({ modkey, "Control" }, "h",
        function(_) resize_client(client.focus, "left") end,
        { description = "resize left", group = "client" }),
    awful.key({ modkey, "Control" }, "l",
        function(_) resize_client(client.focus, "right") end,
        { description = "resize right", group = "client" }),

    -- Number of master clients
    awful.key({ modkey, altkey }, "h",
        function() awful.tag.incnmaster(1, nil, true) end, {
        description = "increase the number of master clients",
        group = "layout"
    }), awful.key({ modkey, altkey }, "l",
        function() awful.tag.incnmaster(-1, nil, true) end, {
        description = "decrease the number of master clients",
        group = "layout"
    }), -- Number of columns
    awful.key({ modkey, altkey }, "k", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, altkey }, "j",
        function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }))

-- Load firefox keyboard shortcuts
local firefox_keys = require("modules.firefox_keys")
hotkeys_popup.add_hotkeys(firefox_keys)

--
for group_name, _ in pairs(firefox_keys) do
    hotkeys_popup.add_group_rules(group_name,
        { rule_any = { class = { "LibreWolf" } } })
end

return keys
