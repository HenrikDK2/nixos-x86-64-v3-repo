{ inputs, lib, pkgs, ... }:

let
  arch = "-march=x86-64-v3 -mtune=generic";
  common = "-O3 ${arch}";
in
pkgs.stdenv.mkDerivation {
  pname = "low-latency-layer-lto-x86_64-v3";
  version = inputs.low-latency-layer.shortRev or "unstable";

  src = inputs.low-latency-layer;

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
  ];

  buildInputs = with pkgs; [
    vulkan-headers
    vulkan-loader
    vulkan-utility-libraries
  ];

  env.NIX_CFLAGS_COMPILE = common;
  env.NIX_CXXFLAGS_COMPILE = common;

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON"
    "-DVulkan_LIBRARY=${pkgs.vulkan-loader}/lib/libvulkan.so"
  ];

  meta = {
    description = "Hardware-agnostic Vulkan input latency reduction layer";
    homepage = "https://github.com/Korthos-Software/low_latency_layer";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
