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
local awful = require("awful")

local mywidgets = {}

function mywidgets.shape(c, w, h) gears.shape.rounded_rect(c, w, h, dpi(7)) end

-- 16:9 floating windows geometry
function mywidgets.geometry(fraction, placement)
    local workarea = awful.screen.focused().workarea
    local x, y, width, height
    local left, up
    left = placement == "up_left" or placement == "bottom_left"
    up = placement == "up_left" or placement == "up_right"
    if workarea.width * 9 > workarea.height * 16 then
        height = math.floor(workarea.height * fraction) - 2 *
            beautiful.useless_gap - 2 * beautiful.border_width
        width = math.floor(height * 16 / 9)
        y = up and (workarea.y + 2 * beautiful.useless_gap) or
            (workarea.y + math.floor(workarea.height * (1 - fraction)))
        x = left and (workarea.x + 2 * beautiful.useless_gap) or
            (workarea.x + workarea.width - 2 * beautiful.useless_gap - 2 *
                beautiful.border_width - width)
    else
        width = math.floor(workarea.width * fraction) - 2 *
            beautiful.useless_gap - 2 * beautiful.border_width
        height = math.floor(width * 9 / 16)
        x = left and (workarea.x + 2 * beautiful.useless_gap) or
            (workarea.x + math.floor(workarea.width * (1 - fraction)))
        y = up and (workarea.y + 2 * beautiful.useless_gap) or
            (workarea.y + workarea.height - 2 * beautiful.useless_gap - 2 *
                beautiful.border_width - height)
    end
    return x, y, width, height
end

-- return a textbox widget of icon font
function mywidgets.textbox(extra)
    local w = {
        align = "center",
        valign = "center",
        id = "text",
        font = beautiful.icon_font,
        widget = wibox.widget.textbox
    }
    for k, v in pairs(extra) do w[k] = v end
    return w
end

-- return a topbar wibox widget table
function mywidgets.block(wdgt, extra)
    local extra = extra or {}
    local w = {
        {
            wdgt,
            left = beautiful.margin_spacing,
            right = beautiful.margin_spacing,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_normal,
        id = "background",
        shape = mywidgets.shape,
        widget = wibox.container.background
    }
    for k, v in pairs(extra) do w[k] = v end
    return w
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

function mywidgets.clickable(wgt)
    local wgt = wibox.widget { wgt,
        id = "background",
        bg = beautiful.bg_button,
        shape = mywidgets.shape,
        widget = wibox.container.background }
    local old_cursor, old_wibox

    wgt:connect_signal("mouse::enter", function(c)
        local text = c:get_children_by_id("text_role")[1]
        if text then
            text:set_markup(markup.fg.color(beautiful.fg_focus,
                mywidgets.mfmt_clear(text.markup)))
        end
        wgt:set_bg(beautiful.bg_focus)
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand2"
    end)

    wgt:connect_signal("mouse::leave", function(c)
        local text = c:get_children_by_id("text_role")[1]
        if text then
            text:set_markup(markup.fg.color(beautiful.fg_button,
                mywidgets.mfmt_clear(text.markup)))
        end
        wgt:set_bg(beautiful.bg_button)
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    return wgt
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

function mywidgets.float_to_rgb(fl, max, sec)
    -- prefer color order: #00ff00 -> #0000ff -> #ff0000
    -- calculation of rgb:
    --            {max, max-sec*fl, max-sec}
    -- correspond color order:
    --            (max-sec, max, max-sec)     green           fl == 0
    --         -> (max-sec, max, max)         green + blue    fl == 0.25
    --         -> (max-sec, max-sec, max)     blue            fl == 0.5
    --         -> (max, max-sec, max)         blue + red      fl == 0.75
    --         -> (max, max-sec, max-sec)     red             fl == 1
    --
    -- fl:        position of color band      (range 0 - 1)
    -- max:       max of rgb hex value        (range 0 - 255)
    -- ratio:     second hex value            (range 0 - 255)
    local function sf(i)
        return (i < 16 and '0' or '') .. string.format("%x", i)
    end

    local max, sec = max or 255, sec or 255
    local r, g, b
    r = max -
        math.floor(
            sec * (fl <= 0.5 and 1 or (fl <= 0.75 and 4 * (0.75 - fl) or 0)))
    g = max -
        math.floor(
            sec * (fl <= 0.25 and 0 or (fl <= 0.5 and 4 * (fl - 0.25) or 1)))
    -- green is too light
    g = math.floor(0.6 * g)
    b = max - math.floor(sec *
        (fl <= 0.25 and 4 * (0.25 - fl) or
            (fl <= 0.75 and 0 or 4 * (fl - 0.75))))
    return "#" .. sf(r) .. sf(g) .. sf(b)
end

function mywidgets.usage_color(usage, max_value, power)
    local value = max_value or 100.0
    local percentage = ((type(usage) == number) and usage or tonumber(usage or 0)) /
        value
    if percentage > 1 then percentage = 1 end
    if power then percentage = math.pow(percentage, 1 / power) end
    return mywidgets.float_to_rgb(percentage)
end

-- clear Pango markup format
function mywidgets.mfmt_clear(markup)
    return string.gsub(markup, "</?[%w%s='#]+>", "")
end

-- return network rate in K, M and G
function mywidgets.KMG(kbf)
    local unit = 'K'
    kbf = tonumber(10 * kbf)
    if kbf > 5120.0 then
        kbf = math.floor(kbf / 1024.0 + 0.5)
        unit = 'M'
    end
    -- return string.format("%.1f", kbf / 10) .. unit
    return string.format("%.1f", kbf / 10) .. unit
end

return mywidgets
