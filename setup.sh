#!/bin/sh

SYSROOT=/opt/aleksa

BINUTILS=binutils-2.37
GCC=gcc-11.2.0


download()
{
    if [ ! -f "./$BINUTILS.tar.gz" ]; then
        wget "https://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.gz"
    fi

    if [ ! -f "./$GCC.tar.gz" ]; then
        wget "https://ftp.gnu.org/gnu/gcc/$GCC/$GCC.tar.gz"
    fi
}

extract()
{
    if [ ! -d "$BINUTILS" ]; then
        tar xzvf "$BINUTILS.tar.gz"
    fi

    if [ ! -d "$GCC" ]; then
        tar xzvf "$GCC.tar.gz"
    fi
}

patch_gnu()
{
    mkdir -p "mine"
    cd "mine" || exit

    if [ ! -d "$BINUTILS" ]; then
        cp -rv "../$BINUTILS" .
        patch -p0 < "../files/aleksa-$BINUTILS.diff"
        cd "$BINUTILS/ld" || exit
        sed -i "s/2.69/2.71/" "Makefile.am"
        aclocal
        automake
        cd "../.."
    fi

    if [ ! -d "$GCC" ]; then
        cp -rv "../$GCC" .
        patch -p0 < "../files/aleksa-$GCC.diff"
        cd "$GCC/libstdc++-v3" || exit
        sed -i "s/2.69/2.71/" "../config/override.m4"
        autoreconf
        cd "../.."
    fi

    cd ".."
}

install_headers()
{
    if [ -d "mykernel" ]; then
        cd "mykernel" || exit
        git pull
        cd ".."
    else
        git clone "https://github.com/aleksav013/mykernel"
    fi

    cd "mykernel" || exit
    ./scripts/install_headers.sh
    cd ".."
}

build_binutils()
{
    cd "./mine/$BINUTILS" || exit

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

    cd "../../.."
}

build_gcc()
{
    cd "./mine/$GCC" || exit

    mkdir -p build
    cd build || exit

    if [ ! -f Makefile ]; then
        ../configure --target=i686-aleksa \
            --prefix="$SYSROOT/usr" \
            --with-sysroot="$SYSROOT" \
            --disable-nls \
            --disable-plugin \
            --enable-languages=c,c++
    fi

    make -j4 all-gcc all-target-libgcc
    make -k check || true
    make install-gcc install-target-libgcc

    cd "../../.."
}

setup_compiler()
{
    if [ -d "mykernel" ]; then
        cd "mykernel" || exit
        git pull
        cd ".."
    else
        git clone "https://github.com/aleksav013/mykernel"
    fi

    cd "mykernel" || exit
    ./scripts/setup_compiler.sh
    cd ".."
}

main()
{
    download
    extract
    patch_gnu
    build_binutils
    install_headers
    build_gcc
    setup_compiler
}

main
