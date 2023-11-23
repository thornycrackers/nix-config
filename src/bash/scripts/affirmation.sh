#!/usr/bin/env bash
# vim: set filetype=sh
#
# Author: Cody Hiar
# Date: 2023-06-29
#
# Description: Script for spitting out an affirmation
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

array=(
    "I cannot control external events, but I can control my own thoughts and actions."
    "I am grateful for what I have in my life, and I will focus on making the most of it."
    "I will face each obstacle as an opportunity for growth and self-improvement."
    "I accept that there are things beyond my control, and I will let go of the need to control them."
    "I will approach each day with a calm and composed mind, ready to handle whatever comes my way."
    "I embrace the present moment and find contentment in the here and now."
    "I will not be disturbed by the opinions of others, as my worth comes from within."
    "I choose to respond to challenges with patience, understanding, and resilience."
    "I am the master of my emotions, and I will not let them dictate my actions."
    "I will strive to live in accordance with my values, regardless of the circumstances."
)
length="${#array[@]}"
index=$((RANDOM % length))
echo "${array[index]}"
