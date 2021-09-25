#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run light-locker
run /usr/lib/polkit-kde-authentication-agent-1
run picom --experimental-backends
run redshift-gtk
run kdeconnect-indicator
run blueman-applet
run nextcloud
run qv2ray
fcitx5 -rd
