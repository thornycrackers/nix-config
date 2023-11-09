#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title asdf
# @raycast.mode silent

# ~/.bookmarks.csv is just a csv that looks like:
#
# duck duck go,https://www.duckduckgo.com
# my other site,https://example.com
#
# The first column being whatever I'd type to autocomplete and the second the
# url.
index=$(cut -d ',' -f 1 ~/.bookmarks.csv | choose -i)
url=$(awk "NR==$((index + 1))" ~/.bookmarks.csv | cut -d ',' -f 2)
open "$url"
