#!/usr/bin/env bash
#
# Author: Cody Hiar
# Date: 2026-04-27
#
# Description: Spawn incus container for running an agent in
set -euo pipefail

# Grab the parent directory name, which is usually the projects name.
PROJECT_PATH=$(realpath .)
RAW_NAME=$(basename "$PROJECT_PATH")
# Strip out leading .'s, if they exist (for dot directories)
NAME=${RAW_NAME#.}
CONTAINER="${NAME}-sandbox"

# 'agent-sandbox' is located in nix config under incus profiles
incus launch agent-base "$CONTAINER" --profile agent-sandbox

# Mount files at /usr/src/app
incus config device add "$CONTAINER" workspace disk \
    source="$PROJECT_PATH" path=/usr/src/app

# Make sure incus applies the user remapping to the mount
incus config device set "$CONTAINER" workspace shift=true

# Wait for networking
incus exec "$CONTAINER" -- bash -c 'until ping -c1 1.1.1.1 &>/dev/null; do sleep 1; done'
