{ mesa }:

mesa.overrideAttrs (old:
  let
    arch = "-march=x86-64-v3 -mtune=generic";
    common = "-O3 ${arch} -fno-semantic-interposition -fno-plt";
  in
  {
    pname = "mesa-x86_64-v3";
    mesonBuildType = "release";

    mesonFlags = (old.mesonFlags or [ ]) ++ [
      "-Db_ndebug=true"
    ];

    env = (old.env or { }) // {
      NIX_CFLAGS_COMPILE = "${old.env.NIX_CFLAGS_COMPILE or ""} ${common}";
      NIX_CXXFLAGS_COMPILE = "${old.env.NIX_CXXFLAGS_COMPILE or ""} ${common}";
      RUSTFLAGS = "-C target-cpu=x86-64-v3 -C opt-level=3";
    };
  })
