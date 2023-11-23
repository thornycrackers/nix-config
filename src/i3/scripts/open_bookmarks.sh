#!/usr/bin/env bash
#
# Author: Cody Hiar
# Date: 2022-01-24
#
# Description: Use rofi to select bookmarks
#
# ~/.bookmarks.csv is just a csv that looks like:
#
# duck duck go,https://www.duckduckgo.com
# my other site,https://example.com
#
# The first column being whatever I'd type to autocomplete and the second the
# url.
#
# Set options:
#   e: Stop script if command fails
#   u: Stop script if unset variable is referenced
#   x: Debug, print commands as they are executed
#   o pipefail:  If any command in a pipeline fails it all fails
#
# IFS: Internal Field Separator
set -uo pipefail
IFS=$'\n\t'

# Use cat to prefix everything with an index number. AFAIK there is not way to
# get rofi to return the index of the selection you've chosen so I used this as
# an alternative.
items=$(cat -n ~/.bookmarks.csv)
selection=$(echo "$items" | awk -F ',' '{print $1}' | rofi -dmenu -i -P Bookmark)
# Make sure there was a selection and I didn't cancel out of the window
if [[ -n "$selection" ]]; then
    index=$(echo "$selection" | awk '{ print $1 }')
    url=$(awk "NR==$index" ~/.bookmarks.csv | cut -d ',' -f 2)
    xdg-open "$url"
fi
