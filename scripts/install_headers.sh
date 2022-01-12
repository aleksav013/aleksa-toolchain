#!/bin/sh

SYSROOT="/opt/aleksa"
GCC_DIR=$(gcc --print-file-name=)

if [ ! -d mykernel ]; then
    git clone "https://github.com/aleksav013/mykernel"
fi

rm -rf "$SYSROOT/usr/include"
mkdir -p "$SYSROOT/usr/include"
cp -r "$GCC_DIR"include/* "$SYSROOT/usr/include"
cp -r mykernel/src/include/* "$SYSROOT/usr/include"
cp "$SYSROOT/usr/include/stdint-gcc.h" "$SYSROOT/usr/include/stdint.h"
