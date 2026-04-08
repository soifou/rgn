#!/usr/bin/env sh

VIDEO_PATH=${XDG_VIDEO_DIR:-~/Videos}/record
file="$VIDEO_PATH/$(date +%F@%T).mp4"

coords=$(./region) || exit 1
[ -z "$coords" ] && exit 1
set -- $coords

X=$1
Y=$2
W=$3
H=$4

ffmpeg \
    -f avfoundation \
    -framerate 30 \
    -i "1:none" \
    -vf "crop=${W}:${H}:${X}:${Y}" \
    -pix_fmt yuv420p \
    $file

notify-send -c screenshot -i "$file" "Record $(basename "$file")" "Saved in ${VIDEO_PATH//"$HOME"/~}"
