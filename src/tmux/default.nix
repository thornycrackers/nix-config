{ pkgs, ... }: {
  wrappers.tmux = {
    basePackage = pkgs.tmux;
    flags = [ "-f ${./tmux.conf}" ];
    pathAdd =
      [ (pkgs.writeShellScriptBin "rolodex" (builtins.readFile ./rolodex)) ];
  };
}
