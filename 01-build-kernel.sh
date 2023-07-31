#!/bin/bash

#####################################################
# 1. BUILD THE KERNEL
#####################################################

LINUX_SRC=${PWD}/linux

export KBUILD_OUTPUT=${PWD}/build/linux-arm64
export KCONFIG_CONFIG=${PWD}/config-arm64

cd $LINUX_SRC
make mrproper

rm -rf $KBUILD_OUTPUT
mkdir -p $KBUILD_OUTPUT

echo "Building kernel..."

ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- make -j 16
