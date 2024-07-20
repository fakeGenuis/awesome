#!/usr/bin/env bash

function run {
  if ! pidof "$1" && which "$1" &> /dev/null; then
    "$@" &
  fi
}

function main {
  case "$1" in
    dim )
      for i in $(seq 1 50); do
        sleep 0.02 && xrandr --output "$_OUT" --brightness "$(echo "1 - 0.01*$i" | bc)"
      done
      ;;
    undim )
      xrandr --output "$_OUT" --brightness 1
      ;;
    lock )
      xrandr --output "$_OUT" --brightness 1
      pkill -9 picom
      betterlockscreen -l
      ;;
    unlock )
      run picom -b
  esac
}

# https://stackoverflow.com/questions/29966449/what-is-the-bash-equivalent-to-pythons-if-name-main/45988155
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
