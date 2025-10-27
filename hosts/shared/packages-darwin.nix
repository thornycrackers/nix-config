pkgs: with pkgs; [
  # The core utils that ship with mac are old
  # NOTE: when I install coreutils it will cause:
  # stty: 'standard input': unable to perform all requested operations
  # When kitty boots up
  # coreutils
  watch
  docker
  colima
]
