{
  description = "The helpful Nix server";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    lazyvim.url = "github:pfassina/lazyvim-nix";
    # nixarr.url = "github:nix-media-server/nixarr";
    nixarr.url = "github:cepehang/nixarr/add-12.2-hash";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      agenix,
      home-manager,
      lazyvim,
      nixarr,
      nixpkgs,
      ...
    }@inputs:
    let
    in
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#navix'
      nixosConfigurations = {
        navix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./nixos/configuration.nix
            agenix.nixosModules.default
            nixarr.nixosModules.default
          ];
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
