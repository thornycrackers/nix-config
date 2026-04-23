#!/usr/bin/env bash
#
# Author: Cody Hiar
# Date: 2026-04-10
#
# Description: Wrap gh-dash so when I run it in a repo directory, it will
# automatically inject the current working dir into repoPaths.

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -n "$REPO" ] && [ -n "$REPO_PATH" ]; then
    export REPO REPO_PATH
    gh-dash --config <(
        yq eval '.repoPaths.[env(REPO)] = env(REPO_PATH)' ~/.config/gh-dash/config.yml
    )
else
    gh-dash
fi
