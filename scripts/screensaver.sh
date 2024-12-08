#!/usr/bin/env bash

function run {
  if ! pidof -x "$1" && which "$1" &>/dev/null; then
    "$@" &
  fi
}

# set current screen out
_OUT=$(xrandr | grep " connected" | cut -d' ' -f1 | head -1)

function main {
  case "$1" in
  dim)
    for i in $(seq 1 50); do
      sleep 0.02 && xrandr --output "$_OUT" --brightness "$(echo "1 - 0.01*$i" | bc)"
    done
    ;;
  undim)
    xrandr --output "$_OUT" --brightness 1
    ;;
  lock)
    xrandr --output "$_OUT" --brightness 1
    # `betterlockscreen`'s option `--off 5` not work if once you cancel that off?!!
    sleep 7 && xset dpms force off &
    betterlockscreen -l
    ;;
  esac
}

# https://stackoverflow.com/questions/29966449/what-is-the-bash-equivalent-to-pythons-if-name-main/45988155
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
