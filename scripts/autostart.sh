#!/usr/bin/env bash

# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "$SCRIPT_DIR"/screensaver.sh

run xsettingsd -c ~/.cache/xsettingsd/xsettingsd.conf
run lxqt-policykit-agent
run redshift
run picom -b

# if one use =via= ...
run xcape -e "Control_L=Escape"

# system tray related
run udiskie -ans
run blueman-applet
run qv2ray
run barrier
run nextcloud
run fcitx5 -rd &>/dev/null

# set screen off time
xset s 920

# Run xidlehook
run xidlehook \
  --detect-sleep \
  `# Don't lock when there's a fullscreen application` \
  --not-when-fullscreen \
  `# Don't lock when there's audio playing` \
  --not-when-audio \
  `# Dim the screen after 60 seconds, undim if user becomes active` \
  --timer 900 \
  `# xrandr --output "$PRIMARY_DISPLAY" --brightness .1` \
  "$SCRIPT_DIR"'/screensaver.sh dim' \
  "$SCRIPT_DIR"'/screensaver.sh undim' \
  `# Undim & lock after 10 more seconds` \
  --timer 10 \
  "$SCRIPT_DIR"'/screensaver.sh lock' \
  "" \
  `# Finally, suspend an hour after it locks`
#   --timer 3600 \
#     'systemctl suspend' \
#     ''
