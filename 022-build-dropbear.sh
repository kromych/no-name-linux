#!/bin/bash

SRC=${PWD}/dropbear
BUILD_DIR=${PWD}/build/dropbear

cd $SRC
autoconf; autoheader

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

cd $BUILD_DIR
$SRC/configure --enable-static
make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" -j `nproc`
