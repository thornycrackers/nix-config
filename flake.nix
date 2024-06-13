{
  description = "Development Machine's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    # Unstable for select packages
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    # Home manager for dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Wrapper manager for wrapping applications (careful updating)
    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Darwin for macbook
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      # https://ayats.org/blog/no-flake-utils/
      # Why you don't need flake-utils.
      # https://xeiaso.net/blog/nix-flakes-1-2022-02-21/
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ my-custom-overlay ];
        }
      );

      # Add unstable packages as an overlay so that they are available in the
      # configs as `pkgs.unstable.<package-name>`
      my-custom-overlay = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = "${prev.system}";
          config.allowUnfree = true;
        };
      };

      # Function for making python shells. That way I can switch between
      # different versions of python as required. It can also be used between
      # different subflakes.
      pythonShell =
        {
          myPkgs,
          pythonVersion,
          additionalPkgs ? [ ],
        }:
        myPkgs.mkShell {
          nativeBuildInputs =
            with myPkgs;
            let
              devpython = pythonVersion.withPackages (
                packages: with packages; [
                  virtualenv
                  pip
                  setuptools
                  wheel
                ]
              );
            in
            [
              devpython
              pkg-config
              libtool
              xmlsec.dev
              libxml2.dev
            ]
            ++ additionalPkgs;
        };
    in
    {
      # Lib is not part of the flake standard, it's a custom entry I add so that
      # I can reuse functions in other flakes.
      lib = {
        inherit forAllSystems nixpkgsFor pythonShell;
      };
      # Default is used by CI for linting. All my linting stuff is already baked
      # into my neovim package so I reuse the packages from there.
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          nvimPackages = import ./src/nvim/packages.nix pkgs;
        in
        {
          default = pkgs.mkShell { buildInputs = nvimPackages; };
          python39 = pythonShell {
            myPkgs = pkgs;
            pythonVersion = pkgs.python39;
          };
          python310 = pythonShell {
            myPkgs = pkgs;
            pythonVersion = pkgs.python310;
          };
          python311 = pythonShell {
            myPkgs = pkgs;
            pythonVersion = pkgs.python311;
          };
          python312 = pythonShell {
            myPkgs = pkgs;
            pythonVersion = pkgs.python312;
          };
        }
      );

      # Create packages out of my wrapped applications. Mostly for fun.
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          mytmux = inputs.wrapper-manager.lib.build {
            inherit pkgs;
            modules = [ ./src/tmux ];
          };
          myneovim = pkgs.callPackage ./src/nvim/myneovim.nix { inherit pkgs; };
        }
      );

      # Expose my wrapped applications. This lets you do stuff like:
      # nix run git+https://github.com/thornycrackers/nix-config#myneovim
      # nix run git+https://github.com/thornycrackers/nix-config#mytmux
      #
      # If you want to test the setups out
      apps = forAllSystems (system: {
        mytmux = {
          type = "app";
          program = "${self.packages.${system}.mytmux}/bin/tmux";
        };
        myneovim = {
          type = "app";
          program = "${self.packages.${system}.myneovim}/bin/nvim";
        };
      });

      # Configuration for development machine
      nixosConfigurations.boston = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          # This makes my custom overlay available for others to use.
          (
            { config, pkgs, ... }:
            {
              nixpkgs.overlays = [ my-custom-overlay ];
            }
          )
          # Configuration for the system
          ./hosts/boston/configuration.nix
          # Home manager stuff, user name needs sync with configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.thorny = import ./hosts/shared/home-linux.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              username = "thorny";
              homedirectory = "/home/thorny";
            };
          }
        ];
      };

      # Configuration for development machine
      nixosConfigurations.snow =
        let
          system = "x86_64-linux";
          flakePkgs = self.packages."${system}";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit flakePkgs;
          };
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            # This makes my custom overlay available for others to use.
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ my-custom-overlay ];
              }
            )
            # Configuration for the system
            ./hosts/snow/configuration.nix
            # Home manager stuff, user name needs sync with configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.thorny = import ./hosts/shared/home-linux-desktop.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                username = "thorny";
                homedirectory = "/home/thorny";
              };
            }
          ];
        };

      # Configuration for development machine
      nixosConfigurations.enigma =
        let
          system = "aarch64-linux";
          flakePkgs = self.packages."${system}";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit flakePkgs;
          };
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            # This makes my custom overlay available for others to use.
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ my-custom-overlay ];
              }
            )
            # Configuration for the system
            ./hosts/enigma/configuration.nix
            # Home manager stuff, user name needs sync with configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.thorny = import ./hosts/shared/home-linux.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                username = "thorny";
                homedirectory = "/home/thorny";
              };
            }
          ];
        };

      # Configuration for temp aarch64vm
      nixosConfigurations.aarch64vm = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          # This makes my custom overlay available for others to use.
          (
            { config, pkgs, ... }:
            {
              nixpkgs.overlays = [ my-custom-overlay ];
            }
          )
          # Configuration for the system
          # This file doesn't exist in the repository. The script that
          # provisions the VM generates the base config with `nixos-generate-config`
          ./hosts/aarch64vm/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.root = import ./hosts/shared/home-linux.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              username = "root";
              homedirectory = "/root";
            };
          }
        ];
      };

      # Darwin config for macbook
      darwinConfigurations."Codys-MacBook-Pro" =
        let
          system = "x86_64-darwin";
          flakePkgs = self.packages."${system}";
        in
        inputs.darwin.lib.darwinSystem {
          inherit system;
          specialArgs = with inputs; {
            inherit wrapper-manager flakePkgs;
          };
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            # This makes my custom overlay available for others to use.
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ my-custom-overlay ];
              }
            )
            ./hosts/macbook/darwin-configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.codyhiar = import ./hosts/shared/home-macbooks.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
            }
          ];
        };

      # Darwin config for macbookwork
      darwinConfigurations."Codys-MacBook-Pro-Work" =
        let
          system = "aarch64-darwin";
          flakePkgs = self.packages."${system}";
        in
        inputs.darwin.lib.darwinSystem {
          inherit system;
          specialArgs = with inputs; {
            inherit wrapper-manager flakePkgs;
          };
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            # This makes my custom overlay available for others to use.
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ my-custom-overlay ];
              }
            )
            ./hosts/macbookwork/darwin-configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.codyhiar = import ./hosts/shared/home-macbooks.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
            }
          ];
        };
    };
}
