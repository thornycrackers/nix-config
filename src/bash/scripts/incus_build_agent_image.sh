#!/usr/bin/env bash
#
# Author: Cody Hiar
# Date: 2026-05-05
#
# Description: Build a base image for agent containers
set -euo pipefail

ALIAS="agent-base"
BUILDER="agent-base-builder"

# Clean up any previous builder
incus delete "$BUILDER" --force 2>/dev/null || true
incus launch images:debian/12 "$BUILDER" --profile agent-sandbox

# Wait for network
incus exec "$BUILDER" -- bash -c 'until ping -c1 1.1.1.1 &>/dev/null; do sleep 1; done'

# Provision
incus exec "$BUILDER" -- bash -s <<'PROVISION'
set -euo pipefail

# Base packages
apt-get update
apt-get install -y --no-install-recommends \
  curl git ca-certificates ripgrep jq \
  build-essential python3 python3-pip \
  sudo vim less

# Node.js (NodeSource for a current version)
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

# Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker

# Claude Code
npm install -g @anthropic-ai/claude-code

# thorny user matching host UID/GID
groupadd -g 1000 thorny
useradd -u 1000 -g 1000 -m -s /bin/bash -G sudo,docker thorny
echo "thorny ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/thorny

# Always jump to the mount directory when entering
echo 'cd /usr/src/app 2>/dev/null || true' >> /home/thorny/.bashrc

# Add alias for running claude without permissions
echo "alias c='claude --dangerously-skip-permissions'" >> /home/thorny/.bashrc

# Additional Defaults
sudo -u thorny mkdir -p /home/thorny/.config /home/thorny/.cache /home/thorny/.npm-global
sudo -u thorny npm config set prefix /home/thorny/.npm-global
echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> /home/thorny/.bashrc
chown -R thorny:thorny /home/thorny

# Cleanup to shrink the image
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
PROVISION

incus stop "$BUILDER"

# Remove old image with same alias if it exists
incus image delete "$ALIAS" 2>/dev/null || true
incus publish "$BUILDER" --alias "$ALIAS" description="Agent sandbox base ($(date -I))"
incus delete "$BUILDER"
incus image list "$ALIAS"

echo "Done"
