{
  inputs = {
    # Reference the root flake, using a relative path
    root.url = "path:../..";
    nixpkgs.follows = "root/nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , root
    ,
    }: {
      devShells = root.lib.forAllSystems (system:
        let
          pkgs = root.lib.nixpkgsFor.${system};
        in
        {
          default = root.lib.pythonShell {
            myPkgs = pkgs;
            pythonVersion = pkgs.python311;
            additionalPkgs = [ pkgs.jdk17_headless pkgs.gnuplot pkgs.graphviz ];
          };
        });
    };
}
