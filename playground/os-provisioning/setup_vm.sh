#!/usr/bin/env bash
# vim: set filetype=sh
#
# Author: Cody Hiar
# Date: 2024-06-25
#
# Description: Script to setup incus container
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

container_name="ubuntu2404"
container_exists=$(incus ls | grep "$container_name" || true)

# Only create the container if it doesn't already exist
if [[ -z "$container_exists" ]]; then
    incus launch images:ubuntu/24.04 "$container_name"
fi

# Install/Enable ssh server for ansible
incus exec "$container_name" -- apt update
incus exec "$container_name" -- apt install -y openssh-server
incus exec "$container_name" -- systemctl enable ssh
incus exec "$container_name" -- systemctl start ssh

# Copy key into machine and set permissions correctly for root user
incus exec "$container_name" -- mkdir -p /root/.ssh
incus exec "$container_name" -- chmod 700 /root/.ssh
incus file push ~/.ssh/id_rsa.pub "$container_name"/root/.ssh/authorized_keys
incus exec "$container_name" -- chmod 600 /root/.ssh/authorized_keys
incus exec "$container_name" -- chown root:root /root/.ssh/authorized_keys

# Create the ansible user
incus exec "$container_name" -- adduser ansible
incus exec "$container_name" -- usermod -aG sudo ansible

# Copy key into machine and set permissions correctly for ansible user
incus exec "$container_name" -- mkdir -p /home/ansible/.ssh
incus exec "$container_name" -- chmod 700 /home/ansible/.ssh
incus file push ~/.ssh/id_rsa.pub "$container_name"/home/ansible/.ssh/authorized_keys
incus exec "$container_name" -- chmod 600 /home/ansible/.ssh/authorized_keys
incus exec "$container_name" -- chown -R ansible:ansible /home/ansible/.ssh

# Generate the inventory file for ansible
# The IP changes every time we create a new container so I automate the
# creation of the inventory file.
ansible_ip=$(incus info "$container_name" | grep "10.0" | awk '{ print $2 }' | cut -d'/' -f1)
cat <<EOF >inventory
[myhosts]
myserver ansible_host=$ansible_ip ansible_user=ansible
EOF
