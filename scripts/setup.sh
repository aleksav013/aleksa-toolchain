#!/bin/sh

SYSROOT=/opt/aleksa

download()
{
    if [ ! -f "./binutils-2.37.tar.gz" ]; then
        wget "https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz"
    fi

    if [ ! -f "./gcc-11.2.0.tar.gz" ]; then
        wget "https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz"
    fi
}

extract()
{
    if [ ! -d "./binutils-2.37" ]; then
        tar xzvf "./binutils-2.37.tar.gz"
    fi

    if [ ! -d "./gcc-11.2.0" ]; then
        tar xzvf "./gcc-11.2.0.tar.gz"
    fi
}

patch_gnu()
{
    mkdir -p "./mine"
    cd "./mine" || exit

    if [ ! -d "./binutils-2.37" ]; then
        cp -r "../binutils-2.37" .
        patch -p0 < "../scripts/aleksa-binutils-2.37.diff"
        cd "./binutils-2.37/ld" || exit
        sed -i "s/2.69/2.71/" "Makefile.am"
        aclocal
        automake
        cd "../.." || exit
    fi

    if [ ! -d "./gcc-11.2.0" ]; then
        cp -r "../gcc-11.2.0" .
        patch -p0 < "../scripts/aleksa-gcc-11.2.0.diff"
        cd "./gcc-11.2.0/libstdc++-v3" || exit
        sed -i "s/2.69/2.71/" "../config/override.m4"
        autoreconf
        cd "../.." || exit
    fi
}

build_binutils()
{
    cd "./binutils-2.37" || exit

    mkdir -p build
    cd build || exit

    if [ ! -f Makefile ]; then
        ../configure --target=i686-aleksa \
            --prefix="$SYSROOT/usr" \
            --with-sysroot="$SYSROOT" \
            --disable-nls
    fi

    make -j4
    make install

    cd "../.." || exit
}

install_headers()
{
    ../scripts/install_headers.sh
}

build_gcc()
{
    cd "./gcc-11.2.0" || exit

    mkdir -p build
    cd build || exit

    if [ ! -f Makefile ]; then
        ../configure --target=i686-aleksa \
            --prefix="$SYSROOT/usr" \
            --with-sysroot="$SYSROOT" \
            --disable-nls \
            --enable-languages=c,c++
    fi

    make -j4 all-gcc
    make -j4 all-target-libgcc

    make -k check || true

    make install-gcc
    make install-target-libgcc

    cd "../.." || exit
}

main()
{
    download
    extract
    patch_gnu
    install_headers
    build_binutils
    build_gcc
}

main
