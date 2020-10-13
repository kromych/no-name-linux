#!/bin/bash

#####################################################
# 1. BUILD THE KERNEL
#####################################################

BUILD_DIR=${PWD}/build
LINUX_SRC=${PWD}/linux
CONFIG_FILE=${PWD}/configs/linux.min_debug
LINUX_BUILD_DIR=$BUILD_DIR/linux

rm -rf $LINUX_BUILD_DIR
mkdir -p $LINUX_BUILD_DIR

echo "Building kernel..."

cd $LINUX_SRC
make KBUILD_OUTPUT=$LINUX_BUILD_DIR KCONFIG_CONFIG=$CONFIG_FILE -j `nproc`

cp $BUILD_DIR/linux/arch/x86_64/boot/bzImage $BUILD_DIR/bzImage.efi
