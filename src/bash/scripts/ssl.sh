#!/usr/bin/env bash
#
#
# Author: Cody Hiar
# Date: 2022-05-13
#
# Description: Launch a kitty window with termdown and move it to the bottom
# right corner of the screen
#
# Set options:
#   e: Stop script if command fails
#   u: Stop script if unset variable is referenced
#   x: Debug, print commands as they are executed
#   o pipefail:  If any command in a pipeline fails it all fails
#
# IFS: Internal Field Separator
set -eo pipefail
IFS=$'\n\t'
hostname="$1"
echo | openssl s_client -servername "$hostname" -connect "$hostname":443 2>/dev/null | openssl x509 -noout -issuer -dates -subject -fingerprint
