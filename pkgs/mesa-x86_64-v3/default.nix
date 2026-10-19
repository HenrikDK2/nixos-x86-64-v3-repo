{ mesa }:

mesa.overrideAttrs (old: {
  pname = "mesa-x86_64-v3";

  NIX_CFLAGS_COMPILE =
    (old.NIX_CFLAGS_COMPILE or "") + ''
      -O3
      -march=x86-64-v3
      -mtune=generic
      -fno-lto
    '';

  NIX_CXXFLAGS_COMPILE =
    (old.NIX_CXXFLAGS_COMPILE or "") + ''
      -O3
      -march=x86-64-v3
      -mtune=generic
      -fno-lto
    '';

  NIX_LDFLAGS =
    (old.NIX_LDFLAGS or "") + " -fno-lto";
})
