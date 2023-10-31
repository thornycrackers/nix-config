#!/usr/bin/env bash
# Script to grow i3 windows

DIR=$1
AMOUNT="30"

if [[ "$DIR" == 'down' ]]; then
    i3-msg "resize grow down ${AMOUNT}" &> /dev/null
    if [[ "$?" == 2 ]]; then
        i3-msg "resize shrink height ${AMOUNT}"
    fi
elif [[ "$DIR" == "left" ]]; then
    i3-msg "resize grow left ${AMOUNT}" &> /dev/null
    if [[ "$?" == 2 ]]; then
        i3-msg "resize shrink width ${AMOUNT}"
    fi
elif [[ "$DIR" == "right" ]]; then
    i3-msg "resize grow right ${AMOUNT}" &> /dev/null
    if [[ "$?" == 2 ]]; then
        i3-msg "resize shrink width ${AMOUNT}"
    fi
elif [[ "$DIR" == "up" ]]; then
    i3-msg "resize grow up ${AMOUNT}" &> /dev/null
    if [[ "$?" == 2 ]]; then
        i3-msg "resize shrink height ${AMOUNT}"
    fi
fi

