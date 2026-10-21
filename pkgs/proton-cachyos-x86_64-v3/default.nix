{ stdenv, fetchurl, ... }:

let
  release = builtins.fromJSON (builtins.readFile ./release.json);
in

stdenv.mkDerivation {
  pname = "proton-cachyos-x86_64-v3";
  version = release.version;

  # Don't push to cache binary
  passthru.cache-binary = false;

  src = fetchurl {
    url = release.url;
    hash = release.hash;
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/share/steam/compatibilitytools.d"
    tar -xf "$src" -C "$out/share/steam/compatibilitytools.d"

    cd "$out/share/steam/compatibilitytools.d"
    mv proton-cachyos-*-x86_64_v3 proton-cachyos-x86_64-v3

    vdf="proton-cachyos-x86_64-v3/compatibilitytool.vdf"

    sed -i -E \
      's/proton-cachyos-[^"]+-x86_64_v3/proton-cachyos-x86_64-v3/g' \
      "$vdf"
  '';

  meta = {
    description = "CachyOS Proton for x86_64-v3";
    platforms = [ "x86_64-linux" ];
  };
}
