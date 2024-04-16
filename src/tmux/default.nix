{pkgs, ...}: {
  wrappers.tmux = {
    basePackage = pkgs.tmux;
    flags = ["-f ${./tmux.conf}"];
    pathAdd = [
      (pkgs.writeShellScriptBin "rolodex.sh" (builtins.readFile ./rolodex.sh))
      (pkgs.writeShellScriptBin "tmux_switch_session.sh" (builtins.readFile ./tmux_switch_sessions.sh))
    ];
  };
}
