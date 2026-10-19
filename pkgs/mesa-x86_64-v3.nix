{ mesa }:
mesa.overrideAttrs (old: {
  pname = "mesa-x86_64-v3";

  env = (old.env or { }) // {
    NIX_CFLAGS_COMPILE =
      (old.env.NIX_CFLAGS_COMPILE or "")
      + " -O3 -march=x86-64-v3 -mtune=generic -fno-lto";

    NIX_CXXFLAGS_COMPILE =
      (old.env.NIX_CXXFLAGS_COMPILE or "")
      + " -O3 -march=x86-64-v3 -mtune=generic -fno-lto";
  };
})
