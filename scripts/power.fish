#!/usr/bin/env fish

set icon_path "$HOME/.local/share/icons/hicolor/128x128/apps/"
set icon_name zenity

set DIR (dirname (status --current-filename))

set ask (zenity --list --title="Power Options" --text="Chose your action" --column="0" "sleep" "lock" "reload" "reboot" "logout" "shutdown" --width=250 --height=250 --hide-header --window-icon=$icon_path$icon_name".png")

switch $ask
    case sleep
        $DIR/i3lock.sh && systemctl suspend
    case reboot
        systemctl reboot
    case shutdown
        systemctl poweroff
    case lock
        $DIR/i3lock.sh
    case logout
        loginctl terminate-session $XDG_SESSION_ID
    case reload
        awesome-client "awesome.restart()"
end
