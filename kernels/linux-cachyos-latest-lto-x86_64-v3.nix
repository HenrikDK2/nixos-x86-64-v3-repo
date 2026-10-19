# Must return a kernelPackages set (anything with a `.kernel` attribute).
#
# Plain re-export of upstream. It is already built for x86-64-v3 with LTO.
#
# To tweak it, wrap the kernel derivation instead:
#
#   { cachyos, linuxPackagesFor }:
#   linuxPackagesFor (cachyos.linux-cachyos-latest-lto-x86_64-v3.overrideAttrs (old: {
#     patches = (old.patches or [ ]) ++ [ ../patches/my-fix.patch ];
#   }))
#
# Don't use -march=native here: CI would compile for the GitHub runner's CPU,
# not for your machine, and the result could crash on yours.
{ cachyos }:
cachyos.linuxPackages-cachyos-latest-lto-x86_64-v3
