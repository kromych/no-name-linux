#!/bin/bash

# First available loop device

LODEV=$(losetup -f)
TARGET=${PWD}/mnt-no-name-linux
ROOTFS=${PWD}/rootfs-arm64
IMG=no-name-linux-arm64.img

# A 64MB file to be used with the loop device

dd if=/dev/zero of=${IMG} bs=1M count=128
chmod 666 ${IMG}
sudo losetup $LODEV ${IMG}

sudo mkfs.ext3 ${LODEV}

rm -rf ${TARGET}
mkdir ${TARGET}

# Mount

sudo mount ${LODEV} ${TARGET}

sudo cp -r ${ROOTFS}/* ${TARGET}

# Unmount the target and detach the loop device
sudo umount ${TARGET}
sudo losetup -d $LODEV
