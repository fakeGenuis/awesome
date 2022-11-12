#!/usr/bin/env fish

# `crontab -e`
# `*/5 * * * * ~/.config/awesome/scripts/wallpaper.fish`

set LIKE_DIR ~/Pictures/Wallpapers
set WALLPAPER_DIR ~/Wallpapers/current
set CURRENT_WALLPAPER (realpath ~/Wallpapers/current/current)

function dislike
    if test -n "$CURRENT_WALLPAPER" -a -f "$CURRENT_WALLPAPER"
        set dislike_dir (dirname "$CURRENT_WALLPAPER")/dislike/
        [ -d "$dislike_dir" ] || mkdir -p "$dislike_dir"
        mv $CURRENT_WALLPAPER "$dislike_dir"
    end
end

function like
    if test -n "$CURRENT_WALLPAPER" -a -f "$CURRENT_WALLPAPER"
        cp $CURRENT_WALLPAPER "$LIKE_DIR" --backup=numbered
    end
end

set -l options h/help n/not-change d/dislike l/like
argparse $options -- $argv
or return

if set -q _flag_help
    printf "Usage: wallpaper [OPTIONS]\n\n"
    printf "Options:\n"
    printf "  -h/--help         print this message\n"
    printf "  -n/--not-change   update current but not set wallpaper\n"
    printf "  -d/--dislike      dislike current wallpaper\n"
    printf "  -l/--like         like current wallpaper\n"
    return 0
end

if set -q _flag_dislike
    dislike
    return 0
end

if set -q _flag_like
    like
    return 0
end

ln -sf (random choice $WALLPAPER_DIR/*) $WALLPAPER_DIR/current
if test -z $_flag_not-change
    DISPLAY=:0 feh --bg-fill "$CURRENT_WALLPAPER"
end
