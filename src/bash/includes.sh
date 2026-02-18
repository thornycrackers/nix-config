#!/usr/bin/env bash

# If I need and custom overides, make them here
# With bash on darwin I needed /bin/stty to resolve first for instance.
# export PATH=~/.local/bin:$PATH
# Add my custom bash scripts to the path
export PATH=$PATH:~/.config/bash/bin
# Add hombrew to the tail end for macbooks
if [[ $(uname -s) == "Darwin" ]]; then
    export PATH=$PATH:/opt/homebrew/bin
fi

# shellcheck disable=SC1091
[[ $- == *i* ]] && source -- "$(blesh-share)"/ble.sh --attach=none

# Git log formats
_git_log_medium_format='%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%w(80,1,2)%+B'
_git_log_oneline_format='%C(green)%h%C(reset) %><(55,trunc)%s%C(red)%d%C(reset) %C(blue)[%an]%C(reset) %C(yellow)%ad%C(reset)%n'

# Aliases
alias t='tmux'
alias c='cd'
alias m='make'
alias a='ack'
alias g='grep'
alias f='find'
alias p='python'
alias ta='tmux attach'
alias n='nvim'
alias inc='nvim ~/.nixpkgs/src/bash/includes.sh'
alias incc='source ~/.bashrc'
alias dod="cd ~/.nixpkgs"
alias lg="lazygit"
alias s="ssh"
alias ldo='lazydocker'
alias nd="nix develop"
alias ..="cd ../"
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ls="ls --color=tty"
alias l="ls --color=tty"
alias me="make enter"
alias mu="make up"
alias mc="make clean"
alias mocr="molecule create"
alias moco="molecule converge"
alias mot="molecule test"
alias mov="molecule verify"
alias mor="molecule destroy && molecule reset"
alias vin="virtualenv .venv && source .venv/bin/activate"
alias vout="deactivate && rm -rf .venv"
alias rmve="rm -rf .venv"
alias ns="nix-shell -p"
alias tf="terraform"
alias tfi="terraform init"
alias twl="terraform workspace list"
alias tws="terraform workspace select"
alias clear="clear -x"
# Branch (b)
alias gb='git branch'
alias gbc='git checkout -b'
alias gbx='git branch -d'
alias gbX='git branch -D'
# Commit (c)
alias gc='git commit --verbose'
alias gcm='git commit --verbose --amend'
alias ga='git add'
alias gca='git add -A; git commit --verbose'
alias gco='git checkout'
alias gcp='git cherry-pick --ff'
# Fetch (f)
alias gfc='git clone'
alias gft='git fetch origin tag --no-tags'
alias gfta='git fetch origin "refs/tags/*:refs/tags/*"'
# Log (l)
alias gls='git log --topo-order --stat --pretty=format:"$_git_log_medium_format}"'
alias gld='git log --topo-order --stat --patch --full-diff --pretty=format:"$_git_log_medium_format"'
alias glg='git log --topo-order --all --graph --date=local --pretty=format:"$_git_log_oneline_format"'
alias glc='git shortlog --summary --numbered'
# Rebase (r)
alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase --interactive'
alias grs='git rebase --skip'
# Merge (m)
alias gm='git merge'
# Push (p)
alias gp='git push'
# Stash (s)
alias gs='git stash'
alias gsa='git stash apply'
alias gsx='git stash drop'
alias gsX='git-stash-clear-interactive'
alias gsl='git stash list'
alias gss='git stash save --include-untracked'
# Working Copy (w)
alias gws='git status --short'
alias gwS='git status'
alias gwd='git diff --no-ext-diff'
alias gwsd='git diff --cached'
alias gwD='git diff --no-ext-diff --word-diff'
alias gwr='git reset'
alias gwrr='git reset HEAD^'
alias gwR='git reset --hard'
alias gwc='git clean -f'
# Docker
# Fun fact for future reference. If you try to put these aliases into functions
# linting will complain that you need to quote them. But, quoting will
# remove wordsplitting which is the mechanism these all depend on to work.
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -a -q) 2> /dev/null'
alias drv='docker volume rm $(docker volume ls -qf dangling=true)'
alias dri='docker rmi -f $(docker images -q)'
# Print the current time in format used in hugo posts
alias hugodate="date --utc +%FT%H:%M:%SZ"
alias rmvenvs="find . -name '.venv' -type d | xargs rm -rf"
alias chx="chmod +x"
alias ap="ansible-playbook"

# cdspell If set, minor errors in the spelling of a directory component in a cd command will be corrected.
shopt -s cdspell

# Bind ^l to `clear -x` to preserve buffer history (only in interactive shells)
[[ $- == *i* ]] && bind -x $'"\C-l":clear -x;'

# Environment Variables
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less -S'
# I get issues all the time with kitty and remote hosts that don't understand
# it. Default to this, customize when needed
export TERM='xterm-256color'
export COOKIECUTTER_CONFIG="$HOME/.config/cookiecutter/config.yml"

# This avoids having to use sudo with virsh commands
# I'll specify a different one if required
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Load keychain on startup
eval "$(keychain --eval --quiet id_rsa)"

# Wrappers for bin stuff that more frequently are used for copying to clipboard than in a pipe
# This saves key strokes since I can press "up arrow" then backwards delete the
# last word instead when switching the input rather than navigating to the middle of:
# <command> <input> | xsel -ib
joinparagraphsclip() {
    # shellcheck disable=SC2317
    joinparagraphs "$1" | xsel -ib
}

mermaidlink2htmlclip() {
    # shellcheck disable=SC2317
    mermaidlink2html "$1" | xsel -ib
}
# Jump to a project diredtory
j() { # Jump to project code
    proj=$(find "$HOME/Work" -mindepth 2 -maxdepth 2 -type d -name "$1")
    if [[ -d "$proj" ]]; then
        cd "$proj" || exit
    else
        echo "$proj does not exist"
    fi
}

rmresult() {
    tmp_store_path=$(readlink result)
    rm -rf result
    nix-store --delete "${tmp_store_path}"
}

nrs() {
    if [[ $(uname -s) == "Linux" ]]; then
        sudo -i nixos-rebuild switch
    elif [[ $(uname -s) == "Darwin" ]]; then
        darwin-rebuild switch --flake ~/.nixpkgs
    else
        echo "unknown platform"
    fi
}

nixc() {
    if [[ $(hostname) == "Codys-MacBook-Pro-Work.local" ]]; then
        nvim ~/.nixpkgs/hosts/macbookwork/darwin-configuration.nix
    elif [[ $(hostname) == "Codys-MacBook-Pro.local" ]]; then
        nvim ~/.nixpkgs/hosts/macbook/darwin-configuration.nix
    elif [[ -f "$HOME/.nixpkgs/hosts/$(hostname)/configuration.nix" ]]; then
        nvim "$HOME/.nixpkgs/hosts/$(hostname)/configuration.nix"
    else
        echo "unknown host"
    fi
}

# Function for loading different versions of python
lkjh() {
    CHOICE=$(echo -ne "python313\npython312\npython311\npython310\npython39" | fzf)
    [ -z "$CHOICE" ] && echo "no choice" && return 1
    nix develop "$HOME"/.nixpkgs#"$CHOICE" -c "$SHELL"
}

# Try to guess python version from .python-version
lkj() {
    if [[ -e ".python-version" ]]; then
        VERSION=$(awk -F'.' '{ print $1$2}' .python-version)
        if [[ "$VERSION" == "39" ]]; then
            nix develop "$HOME"/.nixpkgs#python39 -c "$SHELL"
        elif [[ "$VERSION" == "310" ]]; then
            nix develop "$HOME"/.nixpkgs#python310 -c "$SHELL"
        elif [[ "$VERSION" == "311" ]]; then
            nix develop "$HOME"/.nixpkgs#python311 -c "$SHELL"
        else
            echo "$(cat .python-version) not supported"
        fi
    else
        echo "No .python-version"
    fi
}

# A couple functions here are all related
# Mark a directory as a root, usually the top level directory in a git repo.
# Then, jp with no args is like cd with no args, jumps to the root.
# Autocompletions from jp, however, are directories at the root.
# save typing things like "cd ../../other-dir". I like working with the
# absolute root. Save root between sessions.
set-marked-dir() {
    # Use cache, else, set a default
    if [[ -f ~/.local/state/jpcache ]]; then
        dir=$(cat ~/.local/state/jpcache)
    else
        dir=$HOME
    fi
    export MARKED_DIR="$dir"
}
# run on startup
set-marked-dir

mm() {
    export MARKED_DIR=$PWD
    mkdir -p ~/.local/state
    echo "$MARKED_DIR" >~/.local/state/jpcache
}

jp() {
    # Remove trailing slashes from autocomplete if they exist
    folder="${1%/}"
    proj=$(find "$MARKED_DIR" -mindepth 1 -maxdepth 1 -type d -name "$folder" 2>/dev/null)
    if [[ -n $proj ]]; then
        cd "$proj" || exit
    else
        cd "$MARKED_DIR" || exit
    fi
}

# A lazy command that will wait for me to press enter and then rebuild the my nix config.
# Makes reloads much faster, usually just runs in a tmux pane.
rebuildr() {
    while true; do
        echo -n "Press enter to continue"
        read -r reply
        if [[ $reply == "q" ]]; then
            break
        fi
        nrs
    done
}

# Easy switcher for aws sso profiles
paws() {
    choice="$(grep '\[profile' "$HOME/.aws/config" | awk '{ print $2 }' | tr -d ']' | fzf)"
    export AWS_PROFILE="$choice"
}

# Use curl to heartbeat a website. I use this if I'm doing ops work and want to
# see if there is an interuption to the service
heartbeat() {
    local G='\e[38;5;2m'
    local R='\e[38;5;1m'
    while true; do
        STATUS=$(nice curl -I "$1" 2>/dev/null | grep '200 OK')
        if [[ -n $STATUS ]]; then
            echo -e "$(date) ${G}$1 is up${NC}"
        else
            STATUS=$(nice curl -I "$1" 2>/dev/null | grep 'HTTP/2 200')
            if [[ -n $STATUS ]]; then
                echo -e "$(date) ${G}$1 is up${NC}"
            else
                echo -e "$(date) ${R}$1 is down${NC}"
            fi
        fi
        sleep 2
    done
}

# Small helper function that ensures that both www and non-www redirct to the
# correct url for both http and https
finalurl() {
    curl http://"$1" -s -L -o /dev/null -w '%{url_effective}'
    echo ''
    curl http://www."$1" -s -L -o /dev/null -w '%{url_effective}'
    echo ''
    curl https://"$1" -s -L -o /dev/null -w '%{url_effective}'
    echo ''
    curl https://www."$1" -s -L -o /dev/null -w '%{url_effective}'
    echo ''
}

# If I'm building containers and it it fails:
# 1. I'm not generally watching docker build, I'm doing something else
# 2. Kill all the containers running instead of trying to find the problem
# 3. Rerun the command
# With 93.78% certainty, the command is failing because of port allocation.
mcu() {
    make clean && make up
    if [[ $? == "2" ]]; then
        dstop
        make clean && make up
    fi
}

# lazy command for installing requirements
pipr() {
    if [[ -f "requirements-dev.txt" ]]; then
        pip install -r requirements-dev.txt
    elif [[ -f "requirements.txt" ]]; then
        pip install -r requirements.txt
    else
        echo "no requirements files found"
    fi
}

# Commands for quick redis setup/teardown
start_redis() {
    docker run --publish 6379:6379 --name myredis -d redis
}
stop_redis() {
    docker stop myredis && docker rm myredis
}

start_postgres() {
    [[ -z $POSTGRES_PASSWORD ]] && echo "missing POSTGRES_PASSWORD" && return
    docker run --name mypostgres -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" -p 5432:5432 -d postgres
}
stop_postgres() {
    docker stop mypostgres && docker rm mypostgres
}

dex() {
    choice=$(docker ps --format "{{.Names}}" | fzf)
    docker exec -it "$choice" /bin/bash
}

# Quickly set paths
patha() {
    CHOICE=$(echo -ne "PYTHONPATH\nNIXPKGS" | fzf)
    export "$CHOICE=$(pwd)"
}

# Command for finding all my ghprs across multiple repos since a specific time.
# I use this to figure out what I've worked on in the last quarter
#
# Usage: ghprr NixOS/nixpkgs thornycrackers/nix-config
ghprr() {
    repos=("$@")
    for repo in "${repos[@]}"; do
        local my_dated_prs lines title url number
        my_dated_prs=$(
            gh pr list --repo "$repo" --author @me --state all --json number,title,headRefName,url,createdAt |
                jq --raw-output '. | map(select((.createdAt | strptime("%Y-%m-%dT%H:%M:%SZ")) > ("2024-12-12T00:00:00Z" | strptime("%Y-%m-%dT%H:%M:%SZ")))) | map(del(.createdAt))'
        )
        # Skip if there are no PRs
        if [[ '[]' == "$my_dated_prs" ]]; then
            echo ""
            continue
        fi
        lines=$(echo "$my_dated_prs" |
            jq -r 'map({number,title,headRefName,url}) | (first | keys_unsorted) as $keys | map([to_entries[] | .value]) as $rows | $keys,$rows[] | @csv' |
            tail -n+2)
        if [[ -n "$lines" ]]; then
            mapfile -t lines < <(echo "$lines")
            # Print into html anchors
            for line in "${lines[@]}"; do
                url=$(echo "$line" | csvcut -c '4')
                title=$(echo "$line" | csvcut -c '2' | tr -d '"')
                number=$(echo "$line" | csvcut -c '1')
                echo "<a href=\"$url\">$repo $number: $title</a>"
            done
        fi
        echo ""
    done
}

# Clone all repositories for a given organization. (E.g ghcloneall thornycrackers)
ghcloneall() {
    org_name="$1"
    mapfile -t repos < <(gh repo list "$org_name" --json=name | jq -r '.[].name')
    for repo in "${repos[@]}"; do
        git clone "git@github.com:$org_name/$repo"
    done

}

# Utilities for dealing with nix symlinks
rwh() {
    readlink "$(which "$1")"
}
lwh() {
    less "$(which "$1")"
}
cwh() {
    cat "$(which "$1")"
}
nwh() {
    nvim "$(which "$1")"
}

# Read a file containing hostnames and select one to ssh into
psh() {
    choice=$(fzf <"$1")
    # Save in history for bash
    history -s ssh "${choice}"
    ssh "${choice}"
}

# Same as psh but seelct multiple servers from the file
xpsh() {
    choices=$(fzf --multi --reverse <"$1")
    # Make xpanes use the same tmux as my other sessions
    xpanes -S /tmp/tmux-$UID/default --ssh "${choices[*]}"
}

# Set the Nomad server environment variable
nos() {
    choice=$(fzf <"$1")
    # Save in history for bash
    history -s ssh "${choice}"
    export NOMAD_ADDR="$choice"
}

# "nex" and then interactively select the task to jump into
# Defaults to /bin/bash, some images don't have that though so first arg can
# specify a differnent interpreter
nex() {
    shell=${1:-/bin/bash}
    nomad_jobs=$(nomad job status | tail -n +2 | awk '{ print $1 }')
    choice=$(echo "$nomad_jobs" | fzf)
    if [ -n "$choice" ]; then
        # Choose the first allocation in the list because I care less about the
        # allocation and more about the task itself.
        nomad_job_allocation=$(nomad job status -json "$choice" | jq -r .[].Allocations[].ID | head -n 1)
        nomad_tasks=$(nomad alloc-status -json "$nomad_job_allocation" | jq -r ".TaskStates | keys[]")
        choice=$(echo "$nomad_tasks" | fzf)
        if [ -n "$choice" ]; then
            nomad alloc exec -i -t -task "$choice" "$nomad_job_allocation" "$shell"
        fi
    fi
}

# Find and print all of the python imports in a directory
findreqs() {
    find . -name "*.py" -not -path '*/.venv/*' -print0 | xargs -0 importprinter
}

# "pull down" a port to your local machine.
# For example:
#
# run `python -m http.server --bind 127.0.0.1` on a remote host
# If you try to hit the remote host on port 8000 in your web browser it will
# obviously fail. But if you use this command, you will be able to hit
# `localhost:8000` in your web broser and see everything working
sl() {
    if [ $# -eq 0 ]; then
        # shellcheck disable=SC2016
        echo 'Usage: sl $host $port $bindingaddress(optional)'
        return
    fi
    while true; do
        ssh -nNT -L "$2":localhost:"$2" "$1"
        sleep 10
    done &
}

# Clean
clean_nix_generations() {
    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3
    sudo nix-collect-garbage
}

# Import 2fa images into password store
2faimport() {
    if [[ "$#" -ne 2 ]]; then
        echo 'error in num args'
    else
        # 1 is image 2 is account
        zbarimg -q --raw "${1}" | pass otp append "${2}"
    fi
}
############
# !terraform
############

tfp() {
    local _var_file
    _var_file="$(terraform workspace show).tfvars"
    if [[ -f $_var_file ]]; then
        terraform plan -var-file="$_var_file"
    else
        terraform plan
    fi
}
tfa() {
    local _var_file
    _var_file="$(terraform workspace show).tfvars"
    if [[ -f $_var_file ]]; then
        terraform apply -var-file="$_var_file"
    else
        terraform apply
    fi
}
tfd() {
    local _var_file
    _var_file="$(terraform workspace show).tfvars"
    if [[ -f $_var_file ]]; then
        terraform destroy -var-file="$_var_file"
    else
        terraform destroy
    fi
}

########
# !git
########

# get the name of the current branch
gcb() {
    git rev-parse --abbrev-ref HEAD
}

# Show all the differences in your current branch since it diverged from master
function gbd() {
    if [[ -z "$1" ]]; then
        git diff "$(git merge-base master HEAD)"...HEAD
    else
        git diff "$(git merge-base "$1" HEAD)"...HEAD
    fi
}

# Same as above but just show stat
function gbds() {
    if [[ -z "$1" ]]; then
        git diff --stat "$(git merge-base master HEAD)"...HEAD
    else
        git diff --stat "$(git merge-base "$1" HEAD)"...HEAD
    fi
}

# Use fzf to select multiple files to checkout
# Running checkout will undo your changes to the file
gcoo() {
    local FILES=()
    mapfile -t FILES < <(git diff --name-only | fzf --multi --reverse)
    for FILE in "${FILES[@]}"; do
        git checkout "$FILE"
    done
}

# Checkout a commit based on timerange
gcot() {
    # E.G 2023-01-01
    desired_date="$1" # Replace with your desired date
    target_commit=$(git log --before="$desired_date" -n 1 --format="%H")

    if [ -n "$target_commit" ]; then
        git checkout "$target_commit"
    else
        echo "No commit found before $desired_date"
    fi
}

# Fold staged work into the previous commit to keep clean history
gfo() {
    git commit --amend --no-edit
}

# Interactively select untracked files to remove
gwu() {
    local root_dir
    local files
    root_dir="$(git rev-parse --show-toplevel)"
    mapfile -t files < <(git -C "$root_dir" ls-files --others --exclude-standard | fzf --multi --reverse)
    for file in "${files[@]}"; do
        rm "$root_dir/$file"
    done
}

# Interactively add files
gaa() {
    local root_dir
    local files
    root_dir="$(git rev-parse --show-toplevel)"
    # There's no builtin way (that I know) to filter out files that are already
    # staged so I just grep for "^M " at the start of the line. Likely brittle,
    # but works for now.
    mapfile -t files < <(git -C "$root_dir" status --short | grep -v -E "^M " | awk '{print $2}' | fzf --multi --reverse)
    for file in "${files[@]}"; do
        git add "$root_dir/$file"
    done
}

# Update current branch to it's latest changes from remote
gu() {
    current_branch="$(gcb)"
    git fetch origin "$current_branch"
    git reset --hard origin/"$current_branch"
}

# Pull and rebase local changes
gpl() {
    current_branch="$(gcb)"
    git fetch origin "$current_branch" && git rebase origin/"$current_branch"
}

# Update a remote branch with it's latest latest from origin without having
# to be on that branch
gup() {
    orig_head="$(gcb)"
    for var in "$@"; do
        git checkout "$var"
        git fetch origin "$var"
        git reset --hard origin/"$var"
    done
    git checkout "$orig_head"
}

# Force push current branch
gpf() {
    current_branch="$(gcb)"
    git push origin "$current_branch" --force
}

gpb() {
    current_branch="$(gcb)"
    git push --set-upstream origin "$current_branch"
}

# This function assumes urls of one of the following formats. All others
# will not work:
#
# git@github.com:user/repo.git
# https://github.com/user/repo
#
# It will just clone the repo to repo
gfcc() {
    PROTOCOL=$(echo "$1" | cut -c1-3)
    if [[ "$PROTOCOL" == 'git' ]]; then
        REPO=$(echo "$1" | cut -d'/' -f2 | cut -d'.' -f1)
    elif [[ "$PROTOCOL" == 'htt' ]]; then
        REPO=$(echo "$1" | cut -d'/' -f5)
    fi
    git clone "$1" "$REPO"
}

# Clear out remote refs branches
gbxr() {
    setopt localoptions rmstarsilent
    rm -rf .git/refs/remotes/origin/*
    rm -rf .git/refs/tags/*
    rm -rf .git/packed-refs
}

# Interactively remove local branches
gbxb() {
    local BRANCHES
    mapfile -t BRANCHES < <(git branch | cut -c 3- | fzf --multi --reverse)
    for BRANCH in "${BRANCHES[@]}"; do
        git branch -D "$BRANCH"
    done
}

# Couple of commands for quickly committing and push. Used mostly in dotfiles
# where I'm the only one contributing
gpp() {
    MESSAGE=${1:-auto}
    git commit -m "$MESSAGE" && git push origin master
}

gppa() {
    MESSAGE=${1:-auto}
    git add -A
    git commit -m "$MESSAGE" && git push origin master
}

# Fetch and checkout
gfco() {
    git fetch origin "$1"
    git checkout "$1"
}
gbcc() {
    local BRANCH
    BRANCH="$(git branch | cut -c 3- | fzf)"
    git checkout "$BRANCH"
}

grib() {
    if [[ -z $1 ]]; then
        echo "you forgot target branch name"
        return
    fi
    git rebase -i "$(git merge-base HEAD "$1")"
}

gtd() {
    git push --delete origin "$1"
    git tag --delete "$1"
}

gsr() {
    if [[ -n "$1" ]]; then
        git symbolic-ref refs/heads/master refs/heads/"$1"
        git symbolic-ref refs/remotes/origin/master refs/remotes/origin/"$1"
    else
        git symbolic-ref refs/heads/master refs/heads/main
        git symbolic-ref refs/remotes/origin/master refs/remotes/origin/main
    fi
}

gf() {
    local branch
    local remote

    # If no remote was passed in, assume origin
    if [[ -z "$1" ]]; then
        remote="origin"
    else
        remote="$1"
    fi

    # If no branch was passed in, assume that the current branch is the one we
    # want to fetch.
    if [[ -z "$2" ]]; then
        branch="$(gcb)"
    else
        branch="$2"
    fi

    if [[ "$branch" == "master" ]]; then
        branch="$(git name-rev --name-only master)"
    fi
    git fetch "$remote" "$branch"
}

ghu() {
    # Build the github url for a file
    base_url=$(grep github .git/config | cut -d'@' -f 2 | sed 's/.git//g' | tr ':' '/')
    repo_url="https://$base_url"
    echo "$repo_url/blob/$(gcb)/$1"
}

########
# !aws
########

# List key values of ec2 hosts by a region
awsregionkeys() {
    aws ec2 describe-instances \
        --region "$1" \
        --filters "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[].Tags[?Key == '$2'].Value[] | [] | sort(@)" |
        jq -r '.[]' |
        sort
}
# Get IP for ELB
awselbip() {
    choices=$(
        aws ec2 describe-network-interfaces |
            jq -r '.NetworkInterfaces[].Description' |
            sed '/^[[:space:]]*$/d' |
            grep "^ELB" |
            sort |
            uniq
    )
    choice=$(printf "%s\n" "${choices[@]}" | fzf)
    aws ec2 describe-network-interfaces \
        --filters Name=description,Values="$choice" \
        --query 'NetworkInterfaces[*].PrivateIpAddresses[*].PrivateIpAddress' \
        --output text
}

awsecrlogin() {
    # E.g. 111111111111.dkr.ecr.region.amazonaws.com
    ecr_url=$1
    aws ecr get-login-password | docker login --username AWS --password-stdin "$ecr_url"
}

########
# !tmux
########

# Launch a new tmux session around an existing project
tlo() {
    if [[ -z "$1" ]]; then
        return
    fi
    # Remove trailing slashes from autocomplete if they exist
    desired_proj_name="${1%/}"
    proj_dir=$(find "$HOME/Work" -mindepth 2 -maxdepth 2 -type d -name "$desired_proj_name")
    if [[ -d "$proj_dir" ]]; then
        proj_name=$(basename "$proj_dir")
        tmux new-session -d -c "$proj_dir" -s "$proj_name"
        tmux split-window -v -c "$proj_dir" -t "$proj_name"
        tmux resize-pane -t "$proj_name":1.1 -y 30%
        tmux attach-session -t "$proj_name"
    else
        echo "Project '${1}' was not found"
    fi
}

# Launch a session for mynixpkgs
tlom() {
    local session_name session_dir
    session_name="mynixpkgs"
    session_dir="$HOME/.nixpkgs"
    tmux new-session -d -c "$session_dir" -s "$session_name"
    tmux split-window -v -c "$session_dir" -t "$session_name"
    tmux send-keys -t "$session_name":1.1 "rebuildr" C-m
    tmux resize-pane -t "$session_name":1.1 -y 30%
    tmux attach-session -t "$session_name"
}

# Launch a session for obsidian
tloo() {
    local session_name session_dir
    session_name="obsidian"
    session_dir="$HOME/Obsidian/MyVault"
    tmux new-session -d -c "$session_dir" -s "$session_name"
    tmux split-window -v -c "$session_dir" -t "$session_name"
    tmux attach-session -t "$session_name"
}

############
# !completions
############

# Completions for jumping into projects
function __projects_completion() {
    local suggestions
    suggestions=("$(find "$HOME"/Work/* -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -n1 basename)")
    mapfile -t COMPREPLY < <(compgen -W "${suggestions[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
}
if [[ $- == *i* ]]; then
    complete -F __projects_completion j
    complete -F __projects_completion tlo
fi

# Completions for jumping around marked directory
function __engineering_folders_completion() {
    local suggestions
    suggestions=("$(find "$MARKED_DIR" -maxdepth 1 -type d -not -name '.*' -print0 2>/dev/null | xargs -0 -n1 basename)")
    mapfile -t COMPREPLY < <(compgen -W "${suggestions[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
}
if [[ $- == *i* ]]; then
    complete -F __engineering_folders_completion jp
fi

# ssh completions
_ssh() {
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts=$(grep -i '^host' ~/.ssh/config 2>/dev/null | grep -v '[?*]' | cut -d ' ' -f 2-)
    COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
    return 0
}
if [[ $- == *i* ]]; then
    complete -F _ssh ssh
    complete -F _ssh s
fi
# Note: Completions for c, l, m, g, and p aliases are in home-base.nix
# They must be loaded after bash-completion is enabled
