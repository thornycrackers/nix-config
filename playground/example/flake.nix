{
  inputs = {
    # Reference the root flake, using a relative path
    root.url = "path:../..";
    nixpkgs.follows = "root/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    root,
  }: {
    devShells = root.lib.forAllSystems (system: let
      pkgs = root.lib.nixpkgsFor.${system};
    in {
      default = root.lib.pythonShell pkgs pkgs.python311;
    });
  };
}
