{
  description = "Development Machine's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    # Flake for my neovim setup
    neovimch.url = "git+https://git.codyhiar.com/config/nvim";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      # My custom overlay. Make packages for the different available in the
      # same place. Saves from having to pass imports into modules and manually
      # import the packages
      my-custom-overlay = final: prev: rec {
        # Allow unstable packages to allow unfree packages
        #unstable = import inputs.nixpkgs-unstable {
        #  system = "${system}";
        #  config.allowUnfree = true;
        #};
        neovimch = inputs.neovimch.packages.${prev.system};
      };

    in {
      # Configuration for development machine
      nixosConfigurations.boston = nixpkgs.lib.nixosSystem {
        inherit system;
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
          }
        ];
      };

    };
}
