#!/usr/bin/env bash
# vim: set filetype=sh
#
# Author: Cody Hiar
# Date: 2025-05-20
#
# Description: Run an executable for 5 minutes, then kill it
#
# Set options:
#   e: Stop script if command fails
#   u: Stop script if unset variable is referenced
#   x: Debug, print commands as they are executed
#   o pipefail:  If any command in a pipeline fails it all fails
#
# IFS: Internal Field Separator

app="$1"

# Start the app in background
$app &
sleep 300
pkill "$app"
