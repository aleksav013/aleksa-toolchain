#!/bin/sh

mkdir build
cd build || exit

../configure --target=i686-aleksa \
    --prefix=/usr \
    --with-sysroot=/opt/aleksa \
    --disable-nls \
    --disable-plugin \
    --enable-languages=c,c++

make
