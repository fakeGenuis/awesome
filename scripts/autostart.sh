#!/usr/bin/env bash

function run {
  if ! pgrep -f "$1" && which "$1"; then
    "$@" &
  fi
}

run xsettingsd -c ~/.cache/xsettingsd/xsettingsd.conf
run /usr/bin/lxqt-policykit-agent
run blueman-applet
run qv2ray
# if one use =via= ...
run xcape -e "Control_L=Escape"

fcitx5 -rd &>/dev/null
pidof picom || picom -b
pidof nextcloud || nextcloud &
pidof redshift || redshift &

# systemd (=~/.config/systemd/user/emacs.service=) emacs cannot inherit
# environment variables in shell startup
# emacsclient -e "1" &>/dev/null || env LC_CTYPE='zh_CN.UTF-8' emacs --daemon &

# set screen saver time
xset s 920

# set current screen out
_OUT=$(xrandr | grep " connected" | cut -d' ' -f1 | head -1)
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
  'pkill -9 redshift; for i in $(seq 1 50); do sleep 0.02 && xrandr --output '"$_OUT"' --brightness $(echo "1 - 0.01*$i" | bc); done' \
  'xrandr --output '"$_OUT"' --brightness 1 & redshift' \
  `# Undim & lock after 10 more seconds` \
  --timer 10 \
  'xrandr --output '"$_OUT"' --brightness 1; redshift& betterlockscreen -l' \
  '' \
  `# Finally, suspend an hour after it locks`
#   --timer 3600 \
#     'systemctl suspend' \
#     ''
