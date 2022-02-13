#!/bin/bash

#####################################################
# 1. BUILD THE KERNEL
#####################################################

LINUX_SRC=${PWD}/linux

HEADER_INSTALL=${PWD}/build

export KBUILD_OUTPUT=${PWD}/build/linux
export KCONFIG_CONFIG=${PWD}/configs/linux.config

rm -rf $KBUILD_OUTPUT
mkdir -p $KBUILD_OUTPUT

echo "Building kernel..."

cd $LINUX_SRC
make -j `nproc` mrproper

rm -rf $HEADER_INSTALL/include
mkdir -p $HEADER_INSTALL/include

make -j `nproc`
make -j `nproc` headers_install INSTALL_HDR_PATH=$HEADER_INSTALL
