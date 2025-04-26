{
  description = "Nix configuration for beaststation";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # install agenix, for secret management
    agenix.url = "github:ryantm/agenix";
    # optional, not necessary for the module
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: let
    system = "x86_64-linux";
  in {
    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;

    # NixOS configuration entrypoint
    nixosConfigurations.beaststation = inputs.nixpkgs.lib.nixosSystem {
      # set system
      inherit system;
      specialArgs = {
        inherit inputs;
        inherit (inputs) self;
      };
      # > Our main nixos configuration file <
      modules = [
        ./nixos/configuration.nix

        # make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users = {
              domina = import ./home-manager/domina.nix;
              virt = import ./home-manager/virt.nix;
              vali = import ./home-manager/vali.nix;
            };
          };
        }

        # insert agenix
        inputs.agenix.nixosModules.default
      ];
    };
  };
}
