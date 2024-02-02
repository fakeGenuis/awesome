#!/usr/bin/env bash

export ALL_PROXY=127.0.0.1:8889

if ! curl --max-time 5 google.com &> /dev/null; then
   printf "No network connection!"
   exit 0
fi

{
   checkupdates;
   # paru gives exit code 1 if no package update found, this cause a failed
   # status if run in `systemctl`, completely ignore its exit code
   # https://github.com/Morganamilo/paru/issues/842
   paru -Qua || true;
} > ~/.cache/systemd/upgradablePackages
