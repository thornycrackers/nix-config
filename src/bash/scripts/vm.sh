#!/usr/bin/env bash
# vim: set filetype=sh
#
# Author: Cody Hiar
# Date: 2024-05-10
#
# Description: Wrapper around some common virsh commands
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

# list all the current vms. If nothing shows up it is probably due to LIBVIRT_DEFAULT_URI
# not set to the correct host.
function list_vms {
    virsh list --all
}

function list_networks {
    virsh net-list --all
}

# If you get an error starting a vm about networking you'll need to make sure
# the correct network is running first.
function start_vm {
    vm_choices=$(virsh list --name --state-shutoff)
    if [[ -z "$vm_choices" ]]; then
        echo "No vm's to start"
        exit 0
    fi
    vm_choice=$(virsh list --name --state-shutoff | fzf)
    if [[ -n "$vm_choice" ]]; then
        virsh start "$vm_choice"
    fi
}

function shutdown_vm {
    vm_choices=$(virsh list --name --state-running)
    if [[ -z "$vm_choices" ]]; then
        echo "No vm's to shutdown"
        exit 0
    fi
    vm_choice=$(virsh list --name --state-running | fzf)
    if [[ -n "$vm_choice" ]]; then
        virsh shutdown "$vm_choice"
    fi
}

function watch_vms {
    watch virsh list --all
}

function get_ip {
    vm_choices=$(virsh list --name --state-running)
    if [[ -z "$vm_choices" ]]; then
        echo "No vm's to get ip from"
        exit 0
    fi
    vm_choice=$(virsh list --name --state-running | fzf)
    if [[ -n "$vm_choice" ]]; then
        mac_address="$(virsh dumpxml "$vm_choice" | grep "mac address" | awk -F\' '{ print $2}')"
        echo "$vm_choice: $(arp -an | grep "$mac_address")"
    fi
}

function edit_xml {
    vm_choice=$(virsh list --name --all | fzf)
    if [[ -n "$vm_choice" ]]; then
        virsh edit "$vm_choice"
    fi
}

function undefine {
    vm_choice=$(virsh list --name --all | fzf)
    if [[ -n "$vm_choice" ]]; then
        virsh undefine "$vm_choice"
    fi
}

function define_from_xml_file {
    xml_choice=$(find . -name '*.xml' -printf '%P\n' | fzf)
    if [[ -n "$xml_choice" ]]; then
        virsh define "$xml_choice"
    fi
}

options=(
    "list_vms"
    "list_networks"
    "start_vm"
    "shutdown_vm"
    "watch_vms"
    "get_ip"
    "edit_xml"
    "undefine"
    "define_from_xml_file"
)
selected_option=$(printf '%s\n' "${options[@]}" | fzf || true)
if [ -n "$selected_option" ]; then
    "$selected_option"
fi
