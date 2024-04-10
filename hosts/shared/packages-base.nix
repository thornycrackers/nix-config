pkgs:
with pkgs; [
  ack
  # I want 0.4 of blesh at a minimum
  unstable.blesh
  btop
  csvkit
  curl
  direnv
  entr
  feh
  file
  gh
  git
  gitAndTools.delta
  gnumake
  htop
  jq
  keychain
  lazydocker
  lazygit
  # Want at least version 31 for dupfilefmt
  unstable.lf
  neofetch
  nixos-rebuild
  tailscale
  tmux-xpanes
  wget
  unzip
  zip
]
