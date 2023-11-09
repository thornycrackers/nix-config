#!/usr/bin/env bash
#
# Author: Cody Hiar
# Date: 2020-11-22
#
# Description: Script used to dynamically grow i3 windows.
#
# Set options:
#   e: Stop script if command fails
#   u: Stop script if unset variable is referenced
#   x: Debug, print commands as they are executed
#   o pipefail:  If any command in a pipeline fails it all fails
#
# IFS: Internal Field Separator
set -uo pipefail
IFS=$'\n\t'

DIR=$1
AMOUNT="30"

if [[ "$DIR" == 'down' ]]; then
	i3-msg "resize grow down ${AMOUNT}" &>/dev/null
	if [[ "$?" == 2 ]]; then
		i3-msg "resize shrink height ${AMOUNT}"
	fi
elif [[ "$DIR" == "left" ]]; then
	i3-msg "resize grow left ${AMOUNT}" &>/dev/null
	if [[ "$?" == 2 ]]; then
		i3-msg "resize shrink width ${AMOUNT}"
	fi
elif [[ "$DIR" == "right" ]]; then
	i3-msg "resize grow right ${AMOUNT}" &>/dev/null
	if [[ "$?" == 2 ]]; then
		i3-msg "resize shrink width ${AMOUNT}"
	fi
elif [[ "$DIR" == "up" ]]; then
	i3-msg "resize grow up ${AMOUNT}" &>/dev/null
	if [[ "$?" == 2 ]]; then
		i3-msg "resize shrink height ${AMOUNT}"
	fi
fi
