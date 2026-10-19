{
  description = "Personal package repository (CachyOS kernels and more) compiled for x86-64-v3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      # name -> path, for every *.nix file and every directory in `dir`
      #   pkgs/foo.nix         -> foo
      #   pkgs/foo/default.nix -> foo
      discover = dir:
        lib.pipe (builtins.readDir dir) [
          (lib.filterAttrs (n: t:
            t == "directory" || (t == "regular" && lib.hasSuffix ".nix" n)))
          (lib.mapAttrs' (n: _:
            lib.nameValuePair (lib.removeSuffix ".nix" n) (dir + "/${n}")))
        ];

      pkgFiles = discover ./pkgs;
      kernelFiles = discover ./kernels;

      overlay = final: prev:
        let
          cachyos =
            nix-cachyos-kernel.legacyPackages.${final.stdenv.hostPlatform.system};
          # newScope adds `cachyos` to the auto-arguments, so files only
          # receive it when they ask for it. (Passing it as an explicit
          # callPackage override would hand it to every file and break
          # those that don't accept it, e.g. `{ mesa }:`.)
          call = _: path: final.newScope { inherit cachyos; } path { };
        in
        # Regular packages: derivations
        lib.mapAttrs call pkgFiles
        # Kernels: full kernelPackages sets (for boot.kernelPackages)
        // lib.mapAttrs call kernelFiles;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
        config.allowUnfree = true;
      };
    in
    {
      # Everything CI builds and pushes to Cachix
      packages.${system} =
        lib.mapAttrs (name: _: pkgs.${name}) pkgFiles
        // lib.mapAttrs (name: _: pkgs.${name}.kernel) kernelFiles;

      overlays.default = overlay;

      nixosModules.default = { ... }: {
        nixpkgs.overlays = [ self.overlays.default ];

        nix.settings = {
          extra-substituters = [ "https://nixos-x86-64-v3-repo.cachix.org" ];
          extra-trusted-public-keys = [
            "nixos-x86-64-v3-repo.cachix.org-1:5cNXpGpvFb1eY+WXd9Sm8wdBlU84lhyy8AWI5F1ySJs="
          ];
        };
      };
    };
}
