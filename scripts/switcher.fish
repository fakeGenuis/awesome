#!/usr/bin/env fish

dump_xsettings | grep Light &> /dev/null

if test $status -eq 0
    set search_and_replace Light Dark
else
    set search_and_replace Dark Light
end

sed -i 's/'(string join / $search_and_replace)'/g' ~/.config/xsettingsd/xsettingsd.conf
notify-send -u normal "Awesome" "Change to $search_and_replace[2] GTK theme." -i ASoul-Diana -a awesome
killall -HUP xsettingsd
