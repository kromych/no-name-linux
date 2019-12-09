#!/bin/bash

#####################################################
# 1. BUILD THE KERNEL
#####################################################

LINUX_SRC=~/src/linux

cd $LINUX_SRC
make mrproper

export KBUILD_OUTPUT=~/build/linux
export KCONFIG_CONFIG=~/build/linux/.config
export CONFIG_FRAGMENT=$KBUILD_OUTPUT/.config.fragment

rm -r $KBUILD_OUTPUT
mkdir -p $KBUILD_OUTPUT

make defconfig

cat > $CONFIG_FRAGMENT << EOF 
CONFIG_DEFAULT_HOSTNAME="no-name"
CONFIG_CMDLINE="console=ttyAMA0"
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=n
CONFIG_DEBUG_INFO_SPLIT=n
CONFIG_DEBUG_INFO_DWARF4=n
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

make -j 16
