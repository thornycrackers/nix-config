#!/usr/bin/env bash
set -euo pipefail

DIRECTION="${1:-}"
FOLLOW_FOCUS="${2:-true}"

if [[ -z "$DIRECTION" ]]; then
    tmux display-message "Error: No direction specified"
    exit 1
fi

# Get current pane ID
CURRENT_PANE=$(tmux display-message -p '#{pane_id}')

# Try to find adjacent pane in direction
find_adjacent_pane() {
    local direction=$1
    local flag=""

    case "$direction" in
        left)  flag="-L" ;;
        right) flag="-R" ;;
        up)    flag="-U" ;;
        down)  flag="-D" ;;
    esac

    # Save current pane, try to move, get target pane, move back
    local target
    target=$(tmux select-pane -t "$CURRENT_PANE" "$flag" 2>/dev/null && \
             tmux display-message -p '#{pane_id}' && \
             tmux select-pane -t "$CURRENT_PANE" || echo "")

    if [[ -n "$target" && "$target" != "$CURRENT_PANE" ]]; then
        echo "$target"
    fi
}

ADJACENT_PANE=$(find_adjacent_pane "$DIRECTION")

if [[ -n "$ADJACENT_PANE" ]]; then
    # Simple swap - just exchange pane positions
    tmux swap-pane -s "$CURRENT_PANE" -t "$ADJACENT_PANE"
    # Keep focus on the pane that moved (or stay at original position)
    if [[ "$FOLLOW_FOCUS" == "true" ]]; then
        tmux select-pane -t "$CURRENT_PANE"
    else
        tmux select-pane -t "$ADJACENT_PANE"
    fi
else
    # No adjacent pane - handle cross-window movement for left/right
    PANE_COUNT=$(tmux display-message -p '#{window_panes}')

    if [[ "$DIRECTION" == "left" ]]; then
        CURRENT_INDEX=$(tmux display-message -p '#{window_index}')
        CURRENT_WINDOW=$(tmux display-message -p '#{window_id}')
        FIRST_INDEX=$(tmux list-windows | head -1 | cut -d: -f1)

        if [[ "$CURRENT_INDEX" == "$FIRST_INDEX" && "$PANE_COUNT" -gt 1 ]]; then
            # At first window with multiple panes - create new window
            tmux break-pane -s "$CURRENT_PANE"
            if [[ "$FOLLOW_FOCUS" == "true" ]]; then
                tmux select-pane -t "$CURRENT_PANE"
            else
                tmux select-window -t "$CURRENT_WINDOW"
            fi
        else
            # Either not at first window, or single pane - move to previous (wrap if needed)
            PREV_WINDOW=$(tmux display-message -p -t ':-1' '#{window_id}')
            tmux break-pane -s "$CURRENT_PANE" -d
            tmux join-pane -v -s "$CURRENT_PANE" -t "$PREV_WINDOW"
            if [[ "$FOLLOW_FOCUS" == "true" ]]; then
                tmux select-window -t "$PREV_WINDOW"
                tmux select-pane -t "$CURRENT_PANE"
            else
                tmux select-window -t "$CURRENT_WINDOW"
            fi
        fi
    elif [[ "$DIRECTION" == "right" ]]; then
        CURRENT_INDEX=$(tmux display-message -p '#{window_index}')
        CURRENT_WINDOW=$(tmux display-message -p '#{window_id}')
        LAST_INDEX=$(tmux list-windows | tail -1 | cut -d: -f1)

        if [[ "$CURRENT_INDEX" == "$LAST_INDEX" && "$PANE_COUNT" -gt 1 ]]; then
            # At last window with multiple panes - create new window
            tmux break-pane -s "$CURRENT_PANE"
            if [[ "$FOLLOW_FOCUS" == "true" ]]; then
                tmux select-pane -t "$CURRENT_PANE"
            else
                tmux select-window -t "$CURRENT_WINDOW"
            fi
        else
            # Either not at last window, or single pane - move to next (wrap if needed)
            NEXT_WINDOW=$(tmux display-message -p -t ':+1' '#{window_id}')
            tmux break-pane -s "$CURRENT_PANE" -d
            tmux join-pane -v -s "$CURRENT_PANE" -t "$NEXT_WINDOW"
            if [[ "$FOLLOW_FOCUS" == "true" ]]; then
                tmux select-window -t "$NEXT_WINDOW"
                tmux select-pane -t "$CURRENT_PANE"
            else
                tmux select-window -t "$CURRENT_WINDOW"
            fi
        fi
    fi
    # For up/down with no adjacent pane, do nothing
fi
