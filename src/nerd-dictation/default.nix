{ pkgs, ... }:
# nerd-dictation: offline speech-to-text that types into the focused X11 input.
# Upstream is a single Python script, so there's no real build step. Alongside
# the `nerd-dictation` binary this also ships a `nerd-dictation-toggle` helper
# meant to be bound to a single hotkey: press once to start listening, again to
# stop and type out what was captured.
let
  inherit (pkgs) lib;

  # Upstream source. Update `rev` to pin a commit/tag. After changing it, set
  # sha256 to lib.fakeSha256, build once, then copy the "got:" hash Nix prints.
  nerdSrc = pkgs.fetchFromGitHub {
    name = "nerd-dictation-source";
    owner = "ideasman42";
    repo = "nerd-dictation";
    rev = "main";
    sha256 = "sha256-xjaHrlJvk8bNvWp1VE4EAHi2VJlAutBxUgWB++3Qo+s=";
  };

  # Small English VOSK model (~40MB), pinned in the store so there's no setup.
  voskModel = pkgs.fetchzip {
    name = "vosk-model-small-en-us-0.15";
    url = "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip";
    sha256 = "sha256-CIoPZ/krX+UW2w7c84W3oc1n4zc9BBS/fc8rVYUthuY=";
  };

  # Python with the vosk binding available at runtime. nixpkgs doesn't package
  # vosk, so we build it from the upstream PyPI wheel (see ./vosk.nix).
  pythonEnv = pkgs.python3.withPackages (ps: [ (ps.callPackage ./vosk.nix { }) ]);

  # Runtime tools nerd-dictation shells out to.
  runtimeDeps = [
    pkgs.pulseaudio # provides `parec`
    pkgs.xdotool # types into the focused window
    pythonEnv
  ];

  nerd-dictation = pkgs.stdenv.mkDerivation {
    pname = "nerd-dictation";
    version = "unstable";
    src = nerdSrc;

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = runtimeDeps;

    # No build step; it's a single Python script.
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/nerd-dictation
      # Reference $src directly rather than the unpacked cwd; the upstream layout
      # keeps the script at the repo root and this avoids sourceRoot ambiguity.
      cp $src/nerd-dictation $out/share/nerd-dictation/nerd-dictation.py

      makeWrapper ${pythonEnv}/bin/python3 $out/bin/nerd-dictation \
        --add-flags "$out/share/nerd-dictation/nerd-dictation.py" \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}

      runHook postInstall
    '';

    meta = with lib; {
      description = "Offline speech-to-text that simulates keyboard input on X11";
      homepage = "https://github.com/ideasman42/nerd-dictation";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      mainProgram = "nerd-dictation";
    };
  };

  # Single-hotkey helper. `begin` blocks while it listens, so it's backgrounded;
  # `end` signals that process to stop and type out the result. The model lives
  # in the store, so we point at it explicitly rather than relying on setup in
  # ~/.config/nerd-dictation.
  nerd-dictation-toggle = pkgs.writeShellApplication {
    name = "nerd-dictation-toggle";
    runtimeInputs = [
      nerd-dictation
      pkgs.procps
      pkgs.yad
    ];
    text = ''
      if pgrep -f nerd-dictation.py >/dev/null; then
        nerd-dictation end
      else
        # Show a tray icon for the lifetime of this listening session. Clicking
        # it stops dictation, same as the hotkey. --no-middle stops a stray
        # middle-click from closing the icon while begin keeps running.
        yad --notification --no-middle \
          --image=audio-input-microphone \
          --text="nerd-dictation: listening" \
          --command="nerd-dictation end" &
        icon_pid=$!
        # `begin` blocks until a later toggle (or the icon) runs `end`; whatever
        # the exit reason, drop the icon on the way out.
        trap 'kill "$icon_pid" 2>/dev/null || true' EXIT
        nerd-dictation begin --vosk-model-dir ${voskModel}
      fi
    '';
  };
in
pkgs.symlinkJoin {
  name = "nerd-dictation";
  paths = [
    nerd-dictation
    nerd-dictation-toggle
  ];
}
