#!/usr/bin/env fish

set icon_path "$HOME/.local/share/icons/hicolor/128x128/apps/"
set icon_name zenity
# "~" cannot be translated to $HOME
set save_path ~/Pictures/ScreenShots/

set ask (zenity --list --title="screenshot" --text="save screenshot to" --column="0" "clipboard" "screen" "file" --width=250 --height=175 --hide-header --window-icon=$icon_path$icon_name".png")

switch "$ask"
    case clipboard
        maim -b 3 -us | xclip -selection clipboard -t image/png
        notify-send -u normal "Screen shot send to system clipboard" -i $icon_name -a Maim
    case file
        set saved $save_path(date +%F_%T)".png"
        maim -b 3 -us $saved
        notify-send -u normal "Screen shot save to $saved" -i $icon_name -a Maim
    case "*"
        maim -b 3 -us | feh --no-screen-clip -
end
