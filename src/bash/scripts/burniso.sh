#!/usr/bin/env bash
# vim: set filetype=sh
#
# Author: Cody Hiar
# Date: 2019-03-27
#
# Description: Burn an iso to a disk. I can never remember.
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

ISO=$(find . -type f -name "*.iso" | fzf)
DISK=$(lsblk -l | grep disk | fzf)

echo "Selected disk is:"
echo "$DISK"
echo ""
read -r -p "Are You Sure? [Y/n] " input

DISK_PATH=$(echo "$DISK" | awk '{ print $1 }')

case $input in
[yY][eE][sS] | [yY])
    echo 'run watch "cat /proc/meminfo | grep -i dirty" to watch progress'
    sudo dd if="$ISO" of="/dev/$DISK_PATH" bs=4096 oflag=sync status=progress
    ;;
[nN][oO] | [nN])
    echo "You say No"
    ;;
*)
    echo "Invalid input..."
    exit 1
    ;;
esac
