#!/run/current-system/sw/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title qwer password otp
# @raycast.mode silent

set -eo pipefail
IFS=$'\n\t'

dir="$HOME/.password-store"

print_choices() {
    mapfile -t files < <(find "$dir" -type f -name "*.gpg")
    for file in "${files[@]}"; do
        # convert a full file path "/home/me/.password-store/my/pass.gpg" into "my/pass"
        tmp="${file#"$dir"/}"
        echo "${tmp%.*}"
    done
}
choice=$(print_choices | choose)
otp=$(/run/current-system/sw/bin/pass otp "$choice")

osascript - "$otp" <<EOF
tell application "System Events"
    keystroke "$otp"
end tell
EOF
