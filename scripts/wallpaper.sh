#!/usr/bin/env bash

# =crontab -e=
# =*/5 * * * * DISPLAY=:0 ~/.config/awesome/scripts/wallpaper.sh -n=

CACHE_DIR=~/.cache/wallpaper
FAVORITE_DIR=~/Pictures/Wallpapers/Favorite

[ -d $CACHE_DIR ] || mkdir -p $CACHE_DIR
[ -d $FAVORITE_DIR ] || mkdir -p $FAVORITE_DIR

function get_cur {
    realpath $CACHE_DIR/current
}

function get_prev {
    realpath $CACHE_DIR/previous
}

function set_wallpaper {
    ln -sf "$1" $CACHE_DIR/current
    DISPLAY=:0 feh --bg-fill "$1"
}

function get_slideshow_dir {
    file="$(realpath $CACHE_DIR/slideshow)"
    if [ -d "$file" ]; then
        echo "$file"
    # a file server as symbol link
    # so that slideshow work through nextcloud sync
    elif [ -f "$file" ]; then
        echo "$(dirname "$file")"/"$(head -n 1 "$file")"
    fi
}

function set_slideshow_dir {
    # `ln -f` buggy for symbol to directory
    [ -L $CACHE_DIR/slideshow ] && rm $CACHE_DIR/slideshow
    ln -sv "$1" $CACHE_DIR/slideshow
}

# ./wallpaper.sh -l $(./wallpaper.sh -c) $(basename $(dirname $(./wallpaper.sh -c)))
function like {
    target="$(basename "$1")"
    # if wallpaper from different slideshow directory has same name,
    # but distinct from file already added to favorite directory
    [ -n "$2" ] && target="$2-$target"
    if [ -f $FAVORITE_DIR/"$target" ]; then
        echo "file already exist"
        exit 15
    fi
    cp "$1" $FAVORITE_DIR/"$target"
}

function isliked {
    target="$(basename "$1")"
    [ -n "$2" ] && target="$2-$target"
    [ -f $FAVORITE_DIR/"$target" ] && echo yes || echo no
}

function next {
    if [ ! -d "$(get_slideshow_dir)" ]; then
        echo "slideshow directory not exist!"
        exit 1
    fi
    next_wallpaper=$(find "$(get_slideshow_dir)" -type f | shuf -n 1)
    ln -sf "$(get_cur)" $CACHE_DIR/previous
    ln -sf "$next_wallpaper" $CACHE_DIR/current
    set_wallpaper "$(get_cur)"
}

function print_help {
    printf "Usage: wallpaper [OPTIONS] IMAGE/IMAGE_DIR PREFIX\n\n"
    printf "Options:\n"
    printf "  -c                get current wallpaper\n"
    printf "  -d                get current slideshow directory\n"
    printf "  -h                print this message\n"
    printf "  -i                is IMAGE in favorite\n"
    printf "                        if PREFIX not empty, add before filename\n"
    printf "  -l                copy IMAGE to favorite\n"
    printf "                        if PREFIX not empty, add before filename\n"
    printf "  -n                slideshow next wallpaper\n"
    printf "  -p                get previous wallpaper\n"
    printf "  -r                restore current wallpaper\n"
    printf "  -s                set IMAGE to current wallpaper\n"
    printf "  -w                set IMAGE_DIR to current slideshow directory\n"
}

case "$1" in
    -c) get_cur ;;
    -p) get_prev ;;
    -s) set_wallpaper "$2" ;;
    -r) set_wallpaper "$(get_cur)" ;;
    -d) get_slideshow_dir ;;
    -w) set_slideshow_dir "$2" ;;
    -l) like "$2" "$3" ;;
    -i) isliked "$2" "$3" ;;
    -n) next ;;
    -h) print_help ;;
esac
