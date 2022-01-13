#!/bin/sh

SYSROOT="/opt/aleksa"
SYSROOT_INCLUDE=$SYSROOT/usr/include

if [ ! -d mykernel ]; then
    git clone "https://github.com/aleksav013/mykernel"
fi

rm -rf "$SYSROOT_INCLUDE"
mkdir -p "$SYSROOT_INCLUDE"
cp -r mykernel/src/include/* "$SYSROOT_INCLUDE"
