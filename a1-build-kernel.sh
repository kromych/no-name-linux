#!/bin/bash

#####################################################
# 1. BUILD THE KERNEL
#####################################################

NUM_JOBS=16
LINUX_SRC=${PWD}/linux

export KBUILD_OUTPUT=${PWD}/build/linux-arm64
export KCONFIG_CONFIG=${PWD}/config-arm64

HOST_ARCH=$(uname -m)

# Check if a target architecture is provided as an argument
TARGET_ARCH=${1:-$HOST_ARCH}

if [ "$HOST_ARCH" != "$TARGET_ARCH" ]; then
    CROSS_COMPILE=${TARGET_ARCH}-linux-gnu-
fi

case "$TARGET_ARCH" in
    "arm64")
        KTARGET_ARCH=arm64
        ;;
    "aarch64")
        KTARGET_ARCH=arm64
        ;;
    "x86_64")
        KTARGET_ARCH=x86_64
        ;;
    *)
        echo "Unsupported target architecture for cross-compilation"
        exit 1
        ;;
esac

cd $LINUX_SRC
make mrproper

rm -rf $KBUILD_OUTPUT
mkdir -p $KBUILD_OUTPUT

echo "Building ${KTARGET_ARCH} kernel..."

ARCH=$KTARGET_ARCH CROSS_COMPILE=$CROSS_COMPILE make -j $NUM_JOBS
cp $KBUILD_OUTPUT/arch/arm64/boot/Image ../bootaa64.efi
