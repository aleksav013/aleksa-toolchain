#!/bin/sh

mkdir build
cd build || exit

../configure --target=i686-aleksa \
    --prefix=/usr \
    --with-sysroot=/opt/aleksa \
    --bindir=/usr/bin \
    --libdir=/usr/lib \
    --disable-nls \
    --disable-werror

make
