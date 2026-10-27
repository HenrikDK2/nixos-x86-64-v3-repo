{ inputs, lib, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
inputs.lookapp.packages.${system}.default.overrideAttrs (old: {
  pname = "lookapp-lto-x86_64-v3";

  env = (old.env or {}) // {
    CARGO_PROFILE_RELEASE_OPT_LEVEL = "3";
    CARGO_PROFILE_RELEASE_LTO = "fat";
    CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "1";

    RUSTFLAGS = lib.concatStringsSep " " (lib.filter (s: s != "") [
      (old.env.RUSTFLAGS or "")
      "-C target-cpu=x86-64-v3"
    ]);

    NIX_CFLAGS_COMPILE = lib.concatStringsSep " " (lib.filter (s: s != "") [
      (old.env.NIX_CFLAGS_COMPILE or "")
      "-O3 -march=x86-64-v3 -mtune=generic"
    ]);

    NIX_CXXFLAGS_COMPILE = lib.concatStringsSep " " (lib.filter (s: s != "") [
      (old.env.NIX_CXXFLAGS_COMPILE or "")
      "-O3 -march=x86-64-v3 -mtune=generic"
    ]);
  };
})
