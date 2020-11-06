#!/bin/bash

# First available loop device

LODEV=$(losetup -f)
TARGET=${PWD}/mnt-no-name-linux
ROOTFS=${PWD}/rootfs
IMG=no-name-linux.img

# A 64MB file to be used with the loop device

dd if=/dev/zero of=${IMG} bs=1M count=128
chmod 666 ${IMG}
sudo losetup $LODEV ${IMG}

# Disk partitioning: just one patition spanning al the disk
# gpt instead of msdos makes the disk gpt partitioned

# GRUB embeeds itself after MBR on BIOS/MBR systems, so giving it 4MB, and
# the first partition starts after 4MB.
# On BIOS/GPT systems, a partition of type bios_grub is used

sudo parted --align minimal --script $LODEV mktable msdos mkpart primary 4MB 100% set 1 boot on

# Format and print results

sudo mkfs.ext3 ${LODEV}p1
sudo fdisk -l -u $LODEV

rm -rf ${TARGET}
mkdir ${TARGET}

# Mount

sudo mount ${LODEV}p1 ${TARGET}

sudo cp -r ${ROOTFS}/* ${TARGET}

# Copying modules is not sufficient, grub puts some additional files
#cp grub/usr/lib/grub/i386-pc/* /mnt/target/boot/grub/i386-pc/
sudo grub-install --boot-directory ${TARGET}/boot --target=i386-pc $LODEV

# Unmount the target and detach the loop device
sudo umount ${TARGET}
sudo losetup -d $LODEV
