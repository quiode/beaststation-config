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

  outputs =
    { self
    , nixpkgs
    , home-manager
    , agenix
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    {
      # NixOS configuration entrypoint
      nixosConfigurations.beaststation = nixpkgs.lib.nixosSystem {
        # set system
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        # > Our main nixos configuration file <
        modules = [
          ./nixos/configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.domina = import ./home-manager/domina.nix;
          }

          # insert agenix
          agenix.nixosModules.default
          {
            environment.systemPackages = [ agenix.packages.${system}.default ];
          }
        ];
      };
    };
}
