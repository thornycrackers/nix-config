#!/usr/bin/env bash
# vim: set filetype=sh
#
# Author: Cody Hiar
# Date: 2019-01-11
#
# Description: Rolodex script. Consider the following setup
#
# +------------------------------+-----------------------------+
# |                              |                             |
# |                              |           Pane 3            |
# |                              |                             |
# |        Pane 1                +-----------------------------+
# |                              |                             |
# |                              |         Pane 4              |
# +------------------------------+                             |
# |                              |                             |
# |                              +-----------------------------+
# |       Pane 2                 |                             |
# |                              |                             |
# |                              |       Pane 5                |
# |                              |                             |
# +------------------------------+-----------------------------+
#        Window 1                         Window 2
#
# This is my standard setup. Pane 1 is vim, pane 2-5 are just used for docker
# or w/e else. I almost always want to stick on Window 1 but I want to cycle
# between pane 2-5. This script will simply rotate them in either direction so
# I can stay in window 1 but have a sort of "tabbed" bottom window
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

# Immutable globals
readonly ARGS=("$@")
readonly OPEN=1
readonly CLOSED=0
readonly DRAWER_SIZE=20

# This allows us to redefine using either 1.1 or 1.2 as the pane. I'm growing
# more partial to having 1.1 as drawer to match tmux alt 3 layout
readonly DRAWER_WINDOW_NUMBER="1.1"

get_active_pane() {
    tmux lsp | grep '(active)' | cut -c 1
}

get_number_of_buffer_window_panes() {
    tmux lsp -t 2 | wc -l
}

get_number_of_active_window_panes() {
    tmux lsp | wc -l
}

get_number_of_windows() {
    tmux lsw | wc -l
}

get_prev_pane() {
    PANE_COUNT=$(get_number_of_active_window_panes)
    if [[ "$PANE_COUNT" == '2' ]]; then
        BUFFER_COUNT=$(get_number_of_buffer_window_panes)
        ACTIVE_PANE=$(get_active_pane)
        tmux swap-pane -s "${DRAWER_WINDOW_NUMBER}" -t 2."$BUFFER_COUNT"
        MAX=$((BUFFER_COUNT - 1))
        for i in $(seq 1 "$MAX" | tac); do
            NEXT=$((i + 1))
            tmux swap-pane -s 2."$i" -t 2."$NEXT"
        done
        tmux select-pane -t 1."$ACTIVE_PANE"
    fi
}

get_next_pane() {
    PANE_COUNT=$(get_number_of_active_window_panes)
    if [[ "$PANE_COUNT" == '2' ]]; then
        BUFFER_COUNT=$(get_number_of_buffer_window_panes)
        ACTIVE_PANE=$(get_active_pane)
        tmux swap-pane -s "${DRAWER_WINDOW_NUMBER}" -t 2.1
        MAX=$((BUFFER_COUNT - 1))
        for i in $(seq 1 "$MAX"); do
            NEXT=$((i + 1))
            tmux swap-pane -s 2."$i" -t 2."$NEXT"
        done
        tmux select-pane -t 1."$ACTIVE_PANE"
    fi
}

close_drawer() {
    PANE_COUNT=$(get_number_of_active_window_panes)
    if [[ "$PANE_COUNT" == '2' ]]; then
        WINDOW_COUNT=$(get_number_of_windows)
        if [[ "$WINDOW_COUNT" == '1' ]]; then
            tmux new-window
        fi
        tmux move-pane -s "${DRAWER_WINDOW_NUMBER}" -t 2.1
        tmux move-pane -s 2.1 -t 2.2
        if [[ "$WINDOW_COUNT" == '1' ]]; then
            tmux kill-pane -t 2.2
        fi
        tmux select-window -t 1
    fi
}

open_drawer() {
    PANE_COUNT=$(get_number_of_active_window_panes)
    if [[ "$PANE_COUNT" == '1' ]]; then
        WINDOW_COUNT=$(get_number_of_windows)
        if [[ "$WINDOW_COUNT" == '1' ]]; then
            tmux split-window -c '#{pane_current_path}'
        else
            tmux move-pane -s 2.1
            # Hardcoded swap for having the pane on top
            tmux swap-pane -t 1.2 -s 1.1
        fi
        tmux resize-pane -t "${DRAWER_WINDOW_NUMBER}" -y "${DRAWER_SIZE}"
    fi
}

check_if_drawer_is_open_or_closed() {
    set +e
    tmux showenv DRAWER_PANE_ID &>/dev/null
    RETVAL="$?"
    set -e
    if [[ "$RETVAL" == 0 ]]; then
        echo "${OPEN}"
    else
        echo "${CLOSED}"
    fi
}

toggle_drawer() {
    PANE_COUNT=$(get_number_of_active_window_panes)
    if [[ "$PANE_COUNT" == '1' ]]; then
        open_drawer
    elif [[ "$PANE_COUNT" == '2' ]]; then
        close_drawer
    fi
}

create_new_pane() {
    tmux split-window -c '#{pane_current_path}'
    tmux resize-pane -t "${DRAWER_WINDOW_NUMBER}" -y "${DRAWER_SIZE}"
}

main() {
    ACTION="${1:-}"
    if [[ $ACTION == "toggle" ]]; then
        toggle_drawer
    elif [[ $ACTION == "next" ]]; then
        get_next_pane
    elif [[ $ACTION == "prev" ]]; then
        get_prev_pane
    elif [[ $ACTION == "new" ]]; then
        create_new_pane
    else
        echo "Unrecognized command: ${ACTION}"
    fi
}
main "${ARGS[0]}"
