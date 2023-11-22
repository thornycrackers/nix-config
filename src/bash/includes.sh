#!/usr/bin/env bash

# If I need and custom overides, make them here
# With bash on darwin I needed /bin/stty to resolve first for instance.
export PATH=~/.local/bin:$PATH
# Add my custom bash scripts to the path
export PATH=$PATH:~/.config/bash/bin
# Add hombrew to the tail end for macbooks
if [[ $(uname -s) == "Darwin" ]]; then
	export PATH=$PATH:/opt/homebrew/bin
fi

# shellcheck disable=SC1091
[[ $- == *i* ]] && source "$(blesh-share)/ble.sh" --noattach

# Git log formats
_git_log_medium_format='%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%w(80,1,2)%+B'
_git_log_oneline_format='%C(green)%h%C(reset) %><(55,trunc)%s%C(red)%d%C(reset) %C(blue)[%an]%C(reset) %C(yellow)%ad%C(reset)%n'

# Aliases
alias t='tmux'
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
alias ls="ls --color=tty"
alias me="make enter"
alias lkj='nix develop "$HOME"/.nixpkgs#python39'
alias vin="virtualenv .venv && source .venv/bin/activate"
alias vout="deactivate && rm -rf .venv"
alias ns="nix-shell -p"
alias tf="terraform"
alias tfi="terraform init"
alias twl="terraform workspace list"
alias tws="terraform workspace select"
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
alias gpl='git fetch origin master && git rebase origin/master'
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
alias drm='docker stop $(docker ps -q)'
alias drv='docker volume rm $(docker volume ls -qf dangling=true)'
alias dri='docker rmi -f $(docker images -q)'

# cdspell If set, minor errors in the spelling of a directory component in a cd command will be corrected.
shopt -s cdspell

# Environment Variables
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less -S'
# I get issues all the time with kitty and remote hosts that don't understand
# it. Default to this, customize when needed
export TERM='xterm-256color'
export COOKIECUTTER_CONFIG="$HOME/.config/cookiecutter/config.yml"
# For some reason, docker client is expecting in a different location
# (unix:///run/user/1000/docker.sock) but hardcode for now
export DOCKER_HOST="unix:///run/docker.sock"

# Load keychain on startup
eval "$(keychain --eval --quiet id_rsa)"

# Jump to a project diredtory
j() { # Jump to project code
	proj=$(find "$HOME/Work" -mindepth 2 -maxdepth 2 -type d -name "$1")
	if [[ -d "$proj/code" ]]; then
		cd "$proj/code" || exit
	else
		echo "$proj/code does not exist"
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

# If I'm building containers and it it fails:
# 1. I'm not generally watching docker build, I'm doing something else
# 2. 90% of the time it's another project on port 8000
# So we try to kill the container on port 8000 and try one more time
mcu() {
	make clean && make up
	if [[ $? == "2" ]]; then
		docker stop "$(docker ps | grep "0.0.0.0:8000->" | awk '{ print $1 }')"
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
				jq --raw-output '. | map(select((.createdAt | strptime("%Y-%m-%dT%H:%M:%SZ")) > ("2023-09-11T00:00:00Z" | strptime("%Y-%m-%dT%H:%M:%SZ")))) | map(del(.createdAt))'
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
	xpanes --ssh "${choices[*]}"
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
	local FILES=("$(git diff --name-only | fzf --multi --reverse)")
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
	local ROOT_DIR
	local FILES
	ROOT_DIR="$(git rev-parse --show-toplevel)"
	FILES=("$(git -C "$ROOT_DIR" ls-files --others --exclude-standard | fzf --multi --reverse)")
	for FILE in "${FILES[@]}"; do
		rm "$ROOT_DIR/$FILE"
	done
}

# Update current branch to it's latest changes from remote
gu() {
	current_branch="$(gcb)"
	git fetch origin "$current_branch"
	git reset --hard origin/"$current_branch"
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
# It will just clone the repo to `repo/code` because I like the nested
# directory structure
gfcc() {
	PROTOCOL=$(echo "$1" | cut -c1-3)
	if [[ "$PROTOCOL" == 'git' ]]; then
		REPO=$(echo "$1" | cut -d'/' -f2 | cut -d'.' -f1)
	elif [[ "$PROTOCOL" == 'htt' ]]; then
		REPO=$(echo "$1" | cut -d'/' -f5)
	fi
	git clone "$1" "$REPO"/code
}

# Clear out remote refs branches
gbxr() {
	setopt localoptions rmstarsilent
	rm -rf .git/refs/remotes/origin/*
	rm -rf .git/refs/tags/*
	rm -rf .git/packed-refs
	git fetch origin master
}

# Interactively remove local branches
gbxb() {
	local BRANCHES
	BRANCHES=("$(git branch | cut -c 3- | fzf --multi --reverse)")
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
	# Use name rev to figure out what the master branch is called.
	# Running gsr above sets the ref
	local BRANCH
	if [[ "$2" == "master" ]]; then
		BRANCH="$(git name-rev --name-only master)"
	else
		BRANCH="$2"
	fi
	git fetch "$1" "$BRANCH"
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
#
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
	mapfile -t proj_dirs < <(find "$HOME"/Work/* -mindepth 1 -maxdepth 1 -type d)
	for dir in "${proj_dirs[@]}"; do
		proj_name=$(basename "$dir")
		if [[ "$proj_name" == "$desired_proj_name" ]]; then
			proj_dir="$dir/code"
			tmux new-session -d -c "$proj_dir" -s "$proj_name"
			tmux split-window -v -c "$proj_dir" -t "$proj_name"
			tmux resize-pane -t "$proj_name":1.1 -y 2
			tmux attach-session -t "$proj_name"
			return
		fi
	done
	echo "Project '${1}' was not found"
}

# Launch a session for mynixpkgs
tlom() {
	local session_name session_dir
	session_name="mynixpkgs"
	session_dir="$HOME/.nixpkgs"
	tmux new-session -d -c "$session_dir" -s "$session_name"
	tmux split-window -v -c "$session_dir" -t "$session_name"
	tmux send-keys -t "$session_name":1.1 "rebuildr" C-m
	tmux resize-pane -t "$session_name":1.1 -y 2
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
complete -F __projects_completion j
complete -F __projects_completion tlo

# Completions for jumping around marked directory
function __engineering_folders_completion() {
	local suggestions
	suggestions=("$(find "$MARKED_DIR" -maxdepth 1 -type d -not -name '.*' -print0 2>/dev/null | xargs -0 -n1 basename)")
	mapfile -t COMPREPLY < <(compgen -W "${suggestions[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
}
complete -F __engineering_folders_completion jp
