#!/run/current-system/sw/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title qwer password otp
# @raycast.mode silent

set -eo pipefail
IFS=$'\n\t'

dir="$HOME/.password-store"

print_choices() {
    mapfile -t files < <(find "$dir" -not -name ".*")
    for file in "${files[@]}"; do
        relative_file=${file#"$dir"/}
        basename "$relative_file" ".gpg"
    done
}
choice=$(print_choices | choose)
otp=$(/run/current-system/sw/bin/pass otp "$choice")

osascript - "$otp" <<EOF
tell application "System Events"
    keystroke "$otp"
end tell
EOF
