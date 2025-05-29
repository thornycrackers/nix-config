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
  # At one point the spotify app search just stopped working.
  unstable.spotify
  ## The following wrap chat applications in timers so that they automatically
  #close after 5 minutes. Helps keep distractions in check.
  (writeShellApplication {
    name = "slack";
    # Use unstable slack because I was getting errors on being out of date
    text = ''
      setsid ${unstable.slack}/bin/slack "$@" &
      pid=$!

      TIMEOUT_SECONDS="''${SLACK_TIMEOUT:-300}"
      sleep "$TIMEOUT_SECONDS"

      echo "Timeout reached. Sending SIGTERM to process group..."
      kill -TERM -"$(ps -o pgid= "$pid" | tr -d ' ')"
    '';
  })
  (writeShellApplication {
    name = "Discord";
    text = ''
      setsid ${unstable.discord}/bin/Discord "$@" &
      pid=$!

      TIMEOUT_SECONDS="''${DISCORD_TIMEOUT:-300}"
      sleep "$TIMEOUT_SECONDS"

      echo "Timeout reached. Sending SIGTERM to process group..."
      kill -TERM -"$(ps -o pgid= "$pid" | tr -d ' ')"
    '';
  })
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
