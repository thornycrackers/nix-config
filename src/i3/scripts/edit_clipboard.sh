#!/usr/bin/env bash

# Create a temporary file
temp_file="$HOME/scratch.md"

# Get clipboard content and write it to the temp file
xsel --clipboard --output >"$temp_file"

# Get screen dimensions
screen_width=$(xrandr | grep '*' | awk '{print $1}' | cut -d 'x' -f1 | head -n1)
screen_height=$(xrandr | grep '*' | awk '{print $1}' | cut -d 'x' -f2 | head -n1)

# Calculate 80% of screen dimensions
width=$((screen_width * 80 / 100))
height=$((screen_height * 80 / 100))

# Open kitty with neovim, editing the temp file
# After neovim closes, copy the content back to clipboard and clean up
kitty --class=floating -o initial_window_width=${width} -o initial_window_height=${height} sh -c "nvim '$temp_file' && cat '$temp_file' | xsel --clipboard --input && rm '$temp_file'"
