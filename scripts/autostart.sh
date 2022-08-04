#!/usr/bin/env bash

function run {
  if ! pgrep -f "$1" && which "$1"; then
    "$@" &
  fi
}

run xsettingsd -c ~/.config/xsettingsd/xsettingsd.conf
run /usr/bin/lxqt-policykit-agent
run picom --experimental-backends
run redshift-gtk
run kdeconnect-indicator
run blueman-applet
run qv2ray
run xcape -e "Control_L=Escape;Super_R=Return;Alt_R=BackSpace"

fcitx5 -rd
pidof nextcloud || nextcloud &
emacsclient -e "1" &>/dev/null || env LC_CTYPE='zh_CN.UTF-8' emacs --daemon &

# set screen saver time
xset s 910

# Run xidlehook
if ! pgrep -f xidlehook; then
  xidlehook \
    --detect-sleep \
    `# Don't lock when there's a fullscreen application` \
    --not-when-fullscreen \
    `# Don't lock when there's audio playing` \
    `# --not-when-audio` \
    `# Dim the screen after 60 seconds, undim if user becomes active` \
    --timer 900 \
    `# xrandr --output "$PRIMARY_DISPLAY" --brightness .1` \
    `# xrandr --output "$PRIMARY_DISPLAY" --brightness 1` \
    'notify-send -u critical "xidlehook" "Screen is about to lock" -i xidlehook -a ""' \
    '' \
    `# Undim & lock after 10 more seconds` \
    --timer 10 \
    'betterlockscreen -l' \
    '' \
    `# Finally, suspend an hour after it locks`
  #   --timer 3600 \
  #     'systemctl suspend' \
  #     ''
fi
