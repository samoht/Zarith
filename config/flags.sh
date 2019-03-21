#!/bin/sh
export PKG_CONFIG_PATH="$(opam config var lib)/pkgconfig"
freestanding_ldflags="$(pkg-config gmp-freestanding --libs)"
freestanding_cflags="$(pkg-config gmp-freestanding ocaml-freestanding --cflags)"
xen_cflags="$(pkg-config mirage-xen-posix gmp-xen --cflags) -O2 -pedantic -fomit-frame-pointer -fno-builtin"
xen_ldflags="$(pkg-config gmp-xen --libs)"
echo "$freestanding_ldflags" > ldflags_freestanding
echo "$freestanding_cflags" > cflags_freestanding
echo "$xen_ldflags" > ldflags_xen
echo "$xen_cflags" > cflags_xen
