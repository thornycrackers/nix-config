#!/usr/bin/env bash
#
# shellcheck disable=SC1008
#
# Author: Cody Hiar
# Date: 2022-05-13
#
# Description: Launch a kitty window with termdown and move it to the bottom
# right corner of the screen
#
# Set options:
#   e: Stop script if command fails
#   u: Stop script if unset variable is referenced
#   x: Debug, print commands as they are executed
#   o pipefail:  If any command in a pipeline fails it all fails
#
# IFS: Internal Field Separator
set -eo pipefail
IFS=$'\n\t'

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
}

set -o errtrace
trap traperr ERR

get_screen_width() {
	xdpyinfo | awk '/dimensions:/ { print $2 }' | awk -F'x' '{ print $1 }'
}

get_screen_height() {
	xdpyinfo | awk '/dimensions:/ { print $2 }' | awk -F'x' '{ print $2 }'
}

time="$1"

kitty --class=floating --title termdown-floating bash -c "sleep 0.2; termdown $time; exit" &
sleep 0.2
window_id=$(xdotool search --name termdown-floating)
window_border=5
window_width=800
window_height=300
screen_width=$(get_screen_width)
screen_height=$(get_screen_height)
x=$(("$screen_width" - "$window_border" - "$window_width"))
y=$(("$screen_height" - "$window_border" - "$window_height"))

xdotool windowsize "$window_id" "$window_width" "$window_height"
xdotool windowmove "$window_id" "$x" "$y"
