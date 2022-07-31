#!/usr/bin/env fish

# `crontab -e`
# `*/5 * * * * ~/.config/awesome/scripts/wallpaper.fish`
set -Ux CURRENT_WALLPAPER (random choice ~/Wallpapers/current/*)
DISPLAY=:0 feh --bg-fill "$CURRENT_WALLPAPER"
