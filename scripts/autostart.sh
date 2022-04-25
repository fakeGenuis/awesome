#!/usr/bin/env bash

function run {
  if ! pgrep -f $1; then
    $@&
  fi
}

run /usr/lib/polkit-kde-authentication-agent-1
run picom --experimental-backends
run redshift-gtk
run kdeconnect-indicator
run blueman-applet
run qv2ray
fcitx5 -rd
pidof nextcloud || nextcloud &
emacsclient -e "1" || emacs --daemon &
xcape -e "Control_L=Escape"

# set screen saver time
xset s 910

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run xidlehook
if ! pgrep -f xidlehook ; then
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
      'pgrep i3lock > /dev/null || notify-send -u critical "xidlehook" "Screen is about to lock" -i Fish -a ""' \
      '' \
    `# Undim & lock after 10 more seconds` \
    --timer 10 \
      'pgrep i3lock > /dev/null || ${DIR}/i3lock.sh' \
      '' \
    `# Finally, suspend an hour after it locks`
  #   --timer 3600 \
  #     'systemctl suspend' \
  #     ''
fi
