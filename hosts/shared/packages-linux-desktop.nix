pkgs:
with pkgs;
let
  # Note to future self, if you ran the native install curl script, you'll
  # need to remove the items manually. Should be two files like:
  # ./.mozilla/native-messaging-hosts/tridactyl.json
  # ./.local/share/tridactyl
  myfirefox = firefox-devedition.override { nativeMessagingHosts = [ pkgs.tridactyl-native ]; };
in
[
  kitty
  # Desktop xfce things
  xfce.xfce4-panel
  xfce.xfce4-i3-workspaces-plugin
  xfce.xfce4-screensaver
  nitrogen
  # GUI Apps
  myfirefox
  chromium
  # Was getting notices about it being out of date
  unstable.slack
  spotify
  discord
  # Signal complains when it's out of date. Need to use unstable.
  unstable.signal-desktop
  obsidian
  # Sound
  qjackctl
  playerctl
  pavucontrol
  # Virtualization
  qemu
  guestfs-tools
  # Unstable to install latest distros
  unstable.virt-manager
  # Misc
  activitywatch
  polychromatic
  llama-cpp
  ollama
  openrazer-daemon
  remmina
  (pass.withExtensions (ext: with ext; [ pass-otp ]))
  pinentry-gtk2
  wineWowPackages.staging
  xdotool
  xsel
  zbar
  zathura
]
