#/bin/bash

BUILD_DIR=${PWD}/build

cd socat
autoconf

rm -rf $BUILD_DIR/socat
mkdir -p $BUILD_DIR/socat
mkdir -p $BUILD_DIR/bin

cd $BUILD_DIR/socat
CC=musl-gcc CFLAGS='-static -fPIC' ../../socat/configure
make -j `nproc` socat
cp socat $BUILD_DIR/bin
strip $BUILD_DIR/bin/socat
