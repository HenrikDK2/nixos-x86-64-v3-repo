{
  description = "Packages compiled for x86-64-v3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    proton-cachyos = {
      url = "github:CachyOS/proton-cachyos/cachyos_main";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";

      # CachyOS overlay
      cachyosOverlay = inputs.nix-cachyos-kernel.overlays.pinned;

      # Automatically import every package directory
      packageNames =
        let
          entries = builtins.readDir ./pkgs;
        in
        builtins.filter
          (name: entries.${name} == "directory")
          (builtins.attrNames entries);

      myOverlay = final: prev:
        builtins.listToAttrs (
          map
            (name: {
              inherit name;
              value = final.callPackage
                (./pkgs + "/${name}")
                { inherit inputs; };
            })
            packageNames
        );

      combinedOverlay = final: prev:
        (cachyosOverlay final prev)
        // (myOverlay final prev);

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ combinedOverlay ];
      };
    in
    {
      overlays.default = combinedOverlay;

      # Expose each package as `nix build .#package-name`
      packages.${system} =
        builtins.listToAttrs (
          map
            (name: {
              inherit name;
              value = pkgs.${name};
            })
            packageNames
        );

      nixosModules.default = { ... }: {
        nixpkgs.overlays = [ self.overlays.default ];

        nix.settings = {
          extra-substituters = [
            "https://nixos-x86-64-v3-repo.cachix.org"
          ];

          extra-trusted-public-keys = [
            "nixos-x86-64-v3-repo.cachix.org-1:5cNXpGpvFb1eY+WXd9Sm8wdBlU84lhyy8AWI5F1ySJs="
          ];
        };
      };
    };
}
