{
  description = "Development Machine's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    # Unstable for select packages
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    # Flake for my neovim setup
    neovimch.url = "git+https://git.codyhiar.com/config/nvim";
    neovimch.inputs.nixpkgs.follows = "nixpkgs";
    # Home manager for dotfiles
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Wrapper manager for wrapping applications
    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Darwin for macbook
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # https://ayats.org/blog/no-flake-utils/
      # Why you don't need flake-utils.
      forAllSystems = function:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" ]
        (system:
          function (import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ my-custom-overlay ];
          }));

      my-custom-overlay = final: prev: rec {
        unstable = import inputs.nixpkgs-unstable {
          system = "${prev.system}";
          config.allowUnfree = true;
        };
        neovimchpkgs = inputs.neovimch.packages.${prev.system};
      };

    in {
      packages = forAllSystems (pkgs: rec {
        mytmux = inputs.wrapper-manager.lib.build {
          inherit pkgs;
          modules = [ ./src/tmux ];
        };
        default = mytmux;
      });

      # Configuration for development machine
      nixosConfigurations.boston = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          # This makes my custom overlay available for others to use.
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ my-custom-overlay ]; })
          # Configuration for the system
          ./hosts/boston/configuration.nix
          # Home manager stuff, user name needs sync with configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.thorny = import ./hosts/shared/home-linux.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };

      # Configuration for temp aarch64vm
      nixosConfigurations.aarch64vm = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          # This makes my custom overlay available for others to use.
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ my-custom-overlay ]; })
          # Configuration for the system
          # This file doesn't exist in the repository. The script that
          # provisions the VM generates the base config with `nixos-generate-config`
          ./hosts/aarch64vm/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.root = import ./hosts/shared/home-linux.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };

      # Darwin config for macbook
      darwinConfigurations."Codys-MacBook-Pro" =
        inputs.darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          specialArgs = with inputs; { inherit wrapper-manager; };
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            # This makes my custom overlay available for others to use.
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ my-custom-overlay ];
            })
            ./hosts/macbook/darwin-configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.codyhiar = import ./hosts/macbook/home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

    };
}
