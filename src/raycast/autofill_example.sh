#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title qwer
# @raycast.mode silent

# Example of how to send a variable to osascript to autofill something.

bar="my string"

osascript - "$bar" <<EOF
tell application "System Events"
    keystroke "$bar"
end tell
EOF
