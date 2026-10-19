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
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ combinedOverlay ];
      };

      cachyosOverlay = inputs.nix-cachyos-kernel.overlays.pinned;

      packageNames =
        let
          entries = builtins.readDir ./pkgs;
        in
        builtins.filter
          (name: entries.${name} == "directory")
          (builtins.attrNames entries);

      myOverlay = final: prev:
        builtins.listToAttrs (
          map (name:
            let
              path = ./pkgs + "/${name}";
              packageFunction = import path;
              packageArgs = builtins.functionArgs packageFunction;
              callArgs =
                if builtins.hasAttr "inputs" packageArgs
                then { inherit inputs; }
                else {};
            in
            {
              inherit name;
              value = final.callPackage path callArgs;
            }
          ) packageNames
        );

      combinedOverlay = final: prev:
        (cachyosOverlay final prev)
        // (myOverlay final prev);
    in
    {
      overlays.default = combinedOverlay;

      packages.${system} =
        builtins.listToAttrs (
          map (name: {
            inherit name;
            value =
              if name == "linux-cachyos-latest-lto-x86_64-v3"
              then pkgs.${name}.kernel
              else pkgs.${name};
          }) packageNames
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
