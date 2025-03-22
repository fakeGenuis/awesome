#!/usr/bin/env bash
# This script is written reference to Dave Davenport's =rofi-theme-selecto=
# <qball@gmpclient.org>

# https://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself/4774063
SCRIPTPATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)"

# GTK_DARK="Orchis-Pink-Dark-Compact"
# GTK_LIGHT="Orchis-Pink-Light-Compact"
QT_DARK="OrchisDark"
QT_LIGHT="Orchis"

get_themes() {
    CUR_CATE=""

    echo -e "[Dark] - wallpaper\n[Light] - wallpaper"
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
            echo -e "[${CUR_CATE//' Themes'/}]" "$line" # "\0icon\x1ffile"
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

gen_theme_from_wal() {
    cur_wall="$(${SCRIPTPATH}/wallpaper.sh -c)"
    wal -i "$cur_wall" "${WAL_FLAGS[@]}"
    echo -n "${SR[1]} ${cur_wall}" >~/.cache/wal/current_theme
}

set_theme() {
    theme="$1"
    theme=$(echo "${theme}" | awk '{print $3}')
    echo -n "${SR[1]} ${theme}" >~/.cache/wal/current_theme

    wal --theme "$theme" "${WAL_FLAGS[@]}"
}

if [[ "$theme" == *"wallpaper" ]]; then
    gen_theme_from_wal
else
    set_theme "$theme"
fi

# update all colors
# firefox based browser
pywalfox update
# emacs
emacsclient -e "(load-theme 'ewal-doom-one t)"
emacsclient -s utility -e "(load-theme 'ewal-doom-one t)"
# gtk (only dark/light switch)
sed -i "s/${SR[0]}/${SR[1]}/g;s/${SR[0],,}/${SR[1],,}/g" ~/.cache/xsettingsd/xsettingsd.conf
# TODO change gtk color theme use =oomox=
# /opt/oomox/plugins/theme_oomox/change_color.sh -o oomox -d true -m gtk320 /opt/oomox/scripted_colors/xresources/xresources
killall -HUP xsettingsd
# qt (use kvantum theme, only dark/light switch), app effect after restart 😭️
kvantummanager --set "${QT_THEME}"
# awesome wm
awesome-client "awesome.restart()"
