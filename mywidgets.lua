--  __  __  __   __ __        __  ___   ____     ____   _____   _____   ____
-- |  \/  | \ \ / / \ \      / / |_ _| |  _ \   / ___| | ____| |_   _| / ___|
-- | |\/| |  \ V /   \ \ /\ / /   | |  | | | | | |  _  |  _|     | |   \___ \
-- | |  | |   | |     \ V  V /    | |  | |_| | | |_| | | |___    | |    ___) |
-- |_|  |_|   |_|      \_/\_/    |___| |____/   \____| |_____|   |_|   |____/
--
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local lain = require("lain")
local markup = lain.util.markup

local mywidgets = {}

-- return a textbox widget of icon font
function mywidgets.icon_text(markup)
    local w = {
        align = "center",
        valign = "center",
        id = "text",
        font = beautiful.iconfont,
        widget = wibox.widget.textbox
    }
    if markup then w.markup = markup end
    return w
end

-- return a topbar wibox widget table
function mywidgets.block(wdgt, extra)
    local extra = extra or {}
    local w = {
        {
            wdgt,
            -- left and right margin: make up backgound shape round
            left = dpi(2),
            right = dpi(2),
            -- top and bottom margin: make up border round
            -- top = dpi(2),
            -- bottom = dpi(2),
            widget = wibox.container.margin
        },
        bg = beautiful.bg_normal,
        -- border_width = beautiful.border_width,
        -- border_color = beautiful.wibox_border_color,
        id = "background",
        shape = function(c, w, h)
            gears.shape.rounded_rect(c, w, h, dpi(7))
        end,
        widget = wibox.container.background
    }
    for k, v in pairs(extra) do w[k] = v end
    return w
end

-- return widget background depends on client or tag status
function mywidgets.update_bg(c)
    if c.active or c.selected then
        return beautiful.bg_focus
    elseif c.minimized then
        return beautiful.bg_minimize
    end
    return beautiful.bg_normal
end

-- return markup with color depends on tag status
function mywidgets.update_fg(c, widget_fg)
    local text = mywidgets.mfmt_clear(widget_fg.markup)

    if c.active then
        return markup.fg.color(beautiful.fg_focus, text)
    elseif c.minimized then
        return markup.fg.color(beautiful.fg_minimize, text)
    end

    return markup.fg.color(beautiful.fg_normal, text)
end

-- wrap a wibox with create and update callback function
function mywidgets.wibox_cb(o)
    local o = o or {}
    function o:create_callback(c, index, objects)
        local widget_text = self:get_children_by_id("text")[1]
        local widget_bg = self:get_children_by_id("background")[1]

        if widget_bg then widget_bg.bg = mywidgets.update_bg(c) end
        if widget_text then
            widget_text.markup = mywidgets.update_fg(c, widget_text)
        end
    end

    function o:update_callback(c, index, objects)
        local widget_text = self:get_children_by_id("text")[1]
        local widget_bg = self:get_children_by_id("background")[1]

        if widget_bg then widget_bg.bg = mywidgets.update_bg(c) end
        if widget_text then
            widget_text.markup = mywidgets.update_fg(c, widget_text)
        end
    end
    return o
end

-- clear Pango markup format
function mywidgets.mfmt_clear(markup)
    return string.gsub(markup, "</?[%w%s='#]+>", "")
end

-- return network rate in K, M and G
function mywidgets.KMG(kbf)
    local unit = 'K'
    kbf = tonumber(kbf)
    if kbf > 500.0 then
        kbf = math.floor(kbf / 1024.0 + 0.5)
        unit = 'M'
    end
    return string.format("%.1f", kbf) .. unit
end

return mywidgets
