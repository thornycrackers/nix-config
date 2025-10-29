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

# Loop to allow multiple selections with shift+enter
while true; do
    selections=$(echo "$items" | awk -F ',' '{print $1}' | rofi -dmenu -multi-select -i -P Bookmark \
        -theme-str 'listview { columns: 1; } element { padding: 2px 8px; } element selected { background-color: @selected-normal-background; } element-text { highlight: bold; }' \
        -mesg "Ctrl+Space: Select | Enter: Open Selected & Close | Shift+Enter: Open Selected & Keep Menu")
    exit_code=$?

    # Check if cancelled
    if [[ $exit_code -eq 1 ]]; then
        break
    fi

    # Process all selected items
    if [[ -n "$selections" ]]; then
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                index=$(echo "$line" | awk '{ print $1 }')
                url=$(awk "NR==$index" ~/.bookmarks.csv | cut -d ',' -f 2)
                nohup xdg-open "$url" >/dev/null 2>&1 &
            fi
        done <<<"$selections"

        # If shift+enter was used (exit code 10), continue the loop to keep menu open
        if [[ $exit_code -eq 10 ]]; then
            continue
        else
            # Normal enter (exit code 0), close the menu
            break
        fi
    else
        # No selection made, break
        break
    fi
done
