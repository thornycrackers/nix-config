#!/usr/bin/env bash
#
#
# Author: Cody Hiar
# Date: 2024-03-04
#
# Description: Convert link from mermaid.live into html for embedding
# Written as a script to capture pandoc dependency
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

# sed used to remove the additional <p> tags that are added
echo "$1" |
    pandoc -f markdown -t html |
    sed 's/<[^>]*p>/\n/g'
