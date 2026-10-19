# nixos-x86-64-v3-repo

Packages rebuilt for x86-64-v3, built nightly by CI and cached on Cachix.

## Adding a package

Add a line to `packages.nix`:

```nix
ffmpeg = v3 pkgs.ffmpeg;
```

Anything else works too, e.g. `v3 (pkgs.mesa.override { ... })`, or
`v3 (pkgs.foo.overrideAttrs (old: { patches = old.patches ++ [ ./patches/foo.patch ]; }))`.

`v3` only affects C/C++ built through `stdenv.mkDerivation`. Rust, Go, etc. need
their own flags (`RUSTFLAGS`, `GOAMD64`).

## Using it

```nix
# flake.nix
inputs.v3-repo.url = "github:<you>/nixos-x86-64-v3-repo";

# configuration
imports = [ inputs.v3-repo.nixosModules.default ];   # overlay + Cachix cache

hardware.graphics.package = pkgs.x86_64-v3.mesa;
boot.kernelPackages = pkgs.x86_64-v3.linux-cachyos;
```

Cache hits require your nixpkgs to be the same revision CI built against (see
`flake.lock`); otherwise the packages are built locally.
