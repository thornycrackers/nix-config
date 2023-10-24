pkgs:
with pkgs; [
  # The core utils that ship with mac are old
  coreutils
  # Need up to date ncurses or colors inside of tmux get wonky.
  ncurses
]

