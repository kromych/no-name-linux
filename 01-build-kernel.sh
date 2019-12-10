#!/bin/bash

#####################################################
# 1. BUILD THE KERNEL
#####################################################

LINUX_SRC=${PWD}/linux

export KBUILD_OUTPUT=${PWD}/build/linux
export KCONFIG_CONFIG=${PWD}/build/linux/.config
export CONFIG_FRAGMENT=$KBUILD_OUTPUT/.config.fragment

cd $LINUX_SRC
make mrproper

rm -rf $KBUILD_OUTPUT
mkdir -p $KBUILD_OUTPUT

ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- make defconfig

cat > $CONFIG_FRAGMENT << EOF 
CONFIG_DEFAULT_HOSTNAME="no-name"
CONFIG_CMDLINE=""
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=n
CONFIG_DEBUG_INFO_SPLIT=n
CONFIG_DEBUG_INFO_DWARF4=n
CONFIG_DEBUG_INFO_BTF=n
CONFIG_GDB_SCRIPTS=y
CONFIG_DEBUG_FS=y
CONFIG_STACK_VALIDATION=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
EOF

./scripts/kconfig/merge_config.sh -m $KCONFIG_CONFIG $CONFIG_FRAGMENT

echo "Building kernel..."

ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- make -j 16
