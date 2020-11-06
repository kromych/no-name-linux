#!/bin/bash

#####################################################
# 1. BUILD THE KERNEL
#####################################################

LINUX_SRC=${PWD}/linux

export KBUILD_OUTPUT=${PWD}/build/linux
export KCONFIG_CONFIG=${PWD}/configs/linux.config

cd $LINUX_SRC
make mrproper

rm -rf $KBUILD_OUTPUT
mkdir -p $KBUILD_OUTPUT

echo "Building kernel..."

make -j `nproc`
