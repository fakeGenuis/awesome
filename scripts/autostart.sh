#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run light-locker
run /usr/lib/polkit-kde-authentication-agent-1
run picom
run redshift
run blueman-applet
run nextcloud
run qv2ray
