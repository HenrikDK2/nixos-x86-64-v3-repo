{ stdenv, fetchurl, ... }:

let
  release = builtins.fromJSON (builtins.readFile ./release.json);
in

stdenv.mkDerivation {
  pname = "proton-cachyos-x86_64-v3";
  version = release.version;

  src = fetchurl {
    url = release.url;
    hash = release.hash;
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/share/steam/compatibilitytools.d"
    tar -xf "$src" -C "$out/share/steam/compatibilitytools.d"
  '';

  meta = {
    description = "Proton-CachyOS SLR for x86_64-v3";
    platforms = [ "x86_64-linux" ];
  };
}
