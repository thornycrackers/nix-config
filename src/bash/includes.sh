#!/usr/bin/env bash
# Aliases
alias t='tmux'
alias ta='tmux attach'
alias n='nvim'
alias inc='nvim ~/.nixpkgs/src/zsh/zshrc'
alias incc='source ~/.zshrc'
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
alias ns="nix-shell -p"

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

# Additional includes
# shellcheck disable=SC1091
source "$HOME/.config/bash/git.sh"

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

# Launch a new tmux session around an existing project
tlo() {
	if [[ -z "$1" ]]; then
		return
	fi
	local projs=("$(find "$HOME"/Work/* -mindepth 1 -maxdepth 1 -type d)")
	local proj_name=''
	local proj_dir=''
	for dir in "${projs[@]}"; do
		if [[ $(basename "$dir") == "$1" ]]; then
			proj_name=$(basename "$dir")
			proj_dir="$dir/code"
			tmux new-session -c "${proj_dir}" -s "${proj_name}"
			return
		fi
	done
	echo "Project '${1}' was not found"
}

cwh() {
	cat "$(which "$1")"
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

jp() { # Jump to project code in parsely
	proj=$(find "$HOME/Work/parsely/engineering/code" -mindepth 1 -maxdepth 1 -type d -name "$1")
	cd "$proj" || exit
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

# Stop all docker containers
dstop() { docker stop "$(docker ps -a -q)"; }

# Completions for jumping into projects
function __projects_completion() {
	local suggestions
	suggestions=("$(find "$HOME"/Work/* -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -n1 basename)")
	mapfile -t COMPREPLY < <(compgen -W "${suggestions[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
}
complete -F __projects_completion j
complete -F __projects_completion tlo

# Completions for jumping around folders
function __engineering_folders_completion() {
	local suggestions
	suggestions=("$(find "$HOME"/Work/parsely/engineering/code -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -n1 basename)")
	mapfile -t COMPREPLY < <(compgen -W "${suggestions[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
}
complete -F __engineering_folders_completion jp
