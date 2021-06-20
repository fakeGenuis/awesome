#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run picom
run redshift
# run blueman-applet
# run pasystray
run variety
run nextcloud
run qv2ray
