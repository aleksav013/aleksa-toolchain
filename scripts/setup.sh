#!/bin/sh

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
        patch -p0 < "./scripts/aleksa-binutils-2.37.diff"
    fi

    if [ ! -d "./gcc-11.2.0" ]; then
        cp -r "../gcc-11.2.0" .
        patch -p0 < "../scripts/aleksa-gcc-11.2.0.diff"
    fi
}

build()
{
    cd "./binutils-2.37" || exit
    ../../../scripts/binutils_build.sh
    cd .. || exit

    
    cd "./binutils-2.37" || exit
    ../../../scripts/gcc_build.sh
    cd .. || exit
}

main()
{
    download
    extract
    patch_gnu
#    build
}

main
