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

# Provision as root
incus exec "$BUILDER" -- bash -s <<'PROVISION'
set -x

# Base packages
apt-get update
apt-get install -y --no-install-recommends \
  curl git ca-certificates ripgrep jq \
  build-essential python3 python3-pip \
  sudo vim less

# Setup jj
VERSION=v0.39.0
ARCH=x86_64-unknown-linux-musl
curl -L "https://github.com/jj-vcs/jj/releases/download/${VERSION}/jj-${VERSION}-${ARCH}.tar.gz" -o /tmp/jj.tar.gz
sudo tar xzf /tmp/jj.tar.gz -C /usr/local/bin/ ./jj
rm /tmp/jj.tar.gz
jj --version

# Install gh cli
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# Node.js (NodeSource for a current version)
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

# Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker

# thorny user matching host UID/GID
groupadd -g 1000 thorny
useradd -u 1000 -g 1000 -m -s /bin/bash -G sudo,docker thorny
echo "thorny ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/thorny

# Install pi and other tools
curl -fsSL https://pi.dev/install.sh | sh

# Cleanup to shrink the image
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
PROVISION

# Run user specific provisioning
incus exec "$BUILDER" --user 1000 --group 1000 --cwd /home/thorny --env HOME=/home/thorny -- bash -s <<'PROVISION'
# Setup some defaults
mkdir -p "$HOME/.npm-global" "$home/.cache" "$HOME/.config"
npm config set prefix "$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

npm install -g agent-browser skills @anthropic-ai/claude-code
agent-browser install --with-deps
skills add vercel-labs/agent-browser -g -a claude-code -a pi -y </dev/null
skills add https://github.com/anthropics/skills --skill frontend-design -g -a claude-code -a pi -y </dev/null
skills add https://github.com/dietrichgebert/ponytail --skill ponytail -g -a claude-code -a pi -y </dev/null
skills add https://github.com/obra/superpowers --skill using-superpowers -g -a claude-code -a pi -y </dev/null

# Connect pi to Ollama
mkdir -p /home/thorny/.pi/agent
cat > /home/thorny/.pi/agent/models.json <<'EOF'
{
  "providers": {
    "ollama": {
      "baseUrl": "http://10.0.100.1:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false
      },
      "models": [
        {
          "id": "qwen3:8b",
          "name": "Qwen3 8B (Local)",
          "reasoning": true,
          "input": ["text"],
          "contextWindow": 128000,
          "maxTokens": 32000,
          "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 }
        }
      ]
    }
  }
}
EOF

cat >> /home/thorny/.bashrc <<'BASHRC'
export PATH=$HOME/.npm-global/bin:$PATH
export EDITOR=vim
cd /usr/src/app 2>/dev/null || true
alias c='claude --dangerously-skip-permissions'
BASHRC
PROVISION

incus stop "$BUILDER"

# Remove old image with same alias if it exists
incus image delete "$ALIAS" 2>/dev/null || true
incus publish "$BUILDER" --alias "$ALIAS" description="Agent sandbox base ($(date -I))"
incus delete "$BUILDER"
incus image list "$ALIAS"

echo "Done"
