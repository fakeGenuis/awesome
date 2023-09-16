#!/usr/bin/env bash
# This script is written reference to Dave Davenport's =rofi-theme-selecto=
# <qball@gmpclient.org>

# GTK_DARK="Orchis-Pink-Dark-Compact"
# GTK_LIGHT="Orchis-Pink-Light-Compact"
QT_DARK="Orchis-dark"
QT_LIGHT="Orchis"

get_themes() {
    CUR_CATE=""

    # https://superuser.com/a/284192
    wal --theme | while read -r line; do
        if
            echo "$line" | grep ":$" 1>/dev/null
        then
            # get category of following theme
            # remove colors in output
            # https://stackoverflow.com/a/18000433
            CUR_CATE="$(echo "$line" | cut -d":" -f1 | sed -r 's/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g')"
        else
            echo -e "[$CUR_CATE]" "$line" # "\0icon\x1ffile"
        fi
    done
}

# TODO loop preview theme like =rofi-theme-selector=
# MESG="""<b>Alt-a</b> to accept the new theme"""

theme=$(get_themes | rofi -dmenu -kb-custom-1 "Alt-a" -theme-str 'textbox-prompt-colon {str: "󰔎"; padding: 0.2em 0.4em;}' -theme-str 'entry {placeholder: "Select a theme...";}')
RTR=$?
if [ "${RTR}" = 10 ]; then
    exit 0
# ~Esc~ pressed
elif [ "${RTR}" = 1 ]; then
    exit 0
elif [ "${RTR}" = 65 ]; then
    exit 1
fi

WAL_FLAGS=(-n -e)
SR=(Light Dark)
QT_THEME="${QT_DARK}"
if echo "${theme}" | grep "[Ll]ight" >/dev/null; then
    WAL_FLAGS+=(-l)
    SR=(Dark Light)
    QT_THEME="${QT_LIGHT}"
fi

theme=$(echo "${theme}" | cut -d'-' -f2- | cut -c2-)
echo -n "${SR[1]} ${theme}" >~/.cache/wal/current_theme

# update all colors
wal --theme "$theme" "${WAL_FLAGS[@]}"
# firefox based browser
pywalfox update
# emacs
emacsclient -e "(load-theme 'ewal-doom-one t)"
# gtk (only dark/light switch)
sed -i "s/${SR[0]}/${SR[1]}/g;s/${SR[0],,}/${SR[1],,}/g" ~/.cache/xsettingsd/xsettingsd.conf
# TODO change gtk color theme use =oomox=
# /opt/oomox/plugins/theme_oomox/change_color.sh -o oomox -d true -m gtk320 /opt/oomox/scripted_colors/xresources/xresources
killall -HUP xsettingsd
# qt (use kvantum theme, only dark/light switch)
kvantummanager --set "${QT_THEME}"
# awesome wm
awesome-client "awesome.restart()"
