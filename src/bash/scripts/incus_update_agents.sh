#!/usr/bin/env bash
#
# Author: Cody Hiar
# Date: 2026-04-27
#
# Description: Update all agent containers by copying in required files. I
# guess I could mount too, but this is easy enough.
set -euo pipefail

claude_files=(
    ".claude/.credentials.json"
    ".claude/settings.json"
    ".claude/CLAUDE.md"
    ".claude.json"
)

# Get all running containers matching *-sandbox
containers=$(incus list --format csv -c n status=running '.*-sandbox')

if [ -z "$containers" ]; then
    echo "No running sandbox containers found."
    exit 0
fi

for CONTAINER in $containers; do
    for f in "${claude_files[@]}"; do
        if [ -f "$HOME/$f" ]; then
            incus file push --create-dirs "$HOME/$f" "$CONTAINER/home/thorny/$f"
        fi
    done
    incus exec "$CONTAINER" -- chown -R thorny:thorny /home/thorny/.claude /home/thorny/.claude.json
    echo "Refreshed $CONTAINER"
done
