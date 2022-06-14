#!/usr/bin/env fish

set icon_path "$HOME/.local/share/icons/hicolor/128x128/apps/"
set icon_name zenity

# https://stackoverflow.com/a/36627992
set DIR (dirname (status --current-filename))

set ask (zenity --list --title="Power Options" --text="Chose your action" --column="0" "sleep" "lock" "reload" "reboot" "logout" "shutdown" --width=250 --height=250 --hide-header --window-icon=$icon_path$icon_name".png")

switch $ask
    case sleep
        systemctl suspend
    case reboot
        systemctl reboot
    case shutdown
        systemctl poweroff
    case lock
        betterlockscreen -l
    case logout
        # loginctl terminate-session $XDG_SESSION_ID
        awesome-client "awesome.quit()"
    case reload
        awesome-client "awesome.restart()"
end
