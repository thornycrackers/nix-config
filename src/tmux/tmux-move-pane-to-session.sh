#!/usr/bin/env bash
set -euo pipefail

# Get current pane and session
CURRENT_PANE=$(tmux display-message -p '#{pane_id}')
CURRENT_SESSION=$(tmux display-message -p '#{session_name}')

# List all sessions except current, use fzf to select
SELECTED_SESSION=$(tmux list-sessions -F '#{session_name}' | \
    grep -v "^${CURRENT_SESSION}$" | \
    fzf --prompt="Move pane to session: " --height=40% --reverse)

# If a session was selected
if [[ -n "$SELECTED_SESSION" ]]; then
    # Break pane out to temporary window
    tmux break-pane -s "$CURRENT_PANE" -d

    # Join to the selected session
    tmux join-pane -v -s "$CURRENT_PANE" -t "${SELECTED_SESSION}:"

    # Switch to that session
    tmux switch-client -t "$SELECTED_SESSION"

    # Select the pane we just moved
    tmux select-pane -t "$CURRENT_PANE"
fi
