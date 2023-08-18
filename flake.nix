{
  description = "Development Machine's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    # Flake for my neovim setup
    neovimch.url = "git+https://git.codyhiar.com/config/nvim";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # https://ayats.org/blog/no-flake-utils/
      # Why you don't need flake-utils.
      forAllSystems = function:
        nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
          function (import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ my-custom-overlay ];
          }));

      my-custom-overlay = final: prev: rec {
        neovimch = inputs.neovimch.packages.${prev.system};
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
          ./configuration.nix
          # Home manager stuff, user name needs sync with configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.thorny = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };

    };
}
