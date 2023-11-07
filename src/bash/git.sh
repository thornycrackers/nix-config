#!/usr/bin/env bash
# vi:syntax=bash

# Git styles
_git_log_medium_format='%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%w(80,1,2)%+B'
_git_log_oneline_format='%C(green)%h%C(reset) %><(55,trunc)%s%C(red)%d%C(reset) %C(blue)[%an]%C(reset) %C(yellow)%ad%C(reset)%n'
_git_status_ignore_submodules='none'

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
alias gws='git status --ignore-submodules="$_git_status_ignore_submodules}" --short'
alias gwS='git status --ignore-submodules="$_git_status_ignore_submodules}"'
alias gwd='git diff --no-ext-diff'
alias gwsd='git diff --cached'
alias gwD='git diff --no-ext-diff --word-diff'
alias gwr='git reset'
alias gwrr='git reset HEAD^'
alias gwR='git reset --hard'
alias gwc='git clean -f'

# Functions

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
#
# Fold staged work into the previous commit to keep clean history
gfo() {
	git commit --amend --no-edit
}
#
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
