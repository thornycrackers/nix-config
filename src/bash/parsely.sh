#!/usr/bin/env bash

alias tf="terraform"
alias tfi="terraform init"
alias twl="terraform workspace list"
alias tws="terraform workspace select"

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
