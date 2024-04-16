#!/usr/bin/env bash
# vim: set filetype=sh
#
# Author: Cody Hiar
# Date: 2024-04-16
#
# Description: Switch tmux sessions using fzf but check if fzf was cancelled or
#   not. Easier to have in a script instead of trying to inline in my tmux.conf
#   file.
#
#
# Set options:
#   e: Stop script if command fails
#   u: Stop script if unset variable is referenced
#   x: Debug, print commands as they are executed
#   o pipefail:  If any command in a pipeline fails it all fails
#
# IFS: Internal Field Separator
set -euo pipefail
IFS=$'\n\t'

choice=$(tmux list-sessions |
    sed -E 's/:.*$//' |
    grep -v \"^"$(tmux display-message -p '#S')"\$\" |
    fzf --reverse || true)
if [ -n "$choice" ]; then
    tmux switch-client -t "$choice"
fi
