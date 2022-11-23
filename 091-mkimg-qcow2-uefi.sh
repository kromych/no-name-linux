#!/bin/bash

# sudo yum install libguestfs-tools libguestfs guestfs-tools nbdfuse qemu-utils -y

rm -f no-name-linux.qcow2
qemu-img create -f qcow2 no-name-linux.qcow2 512M
qemu-img create -f qcow2 snapshots.qcow2 32G

sudo rm -rf mnt-no-name-linux
sudo mkdir -p mnt-no-name-linux/{efi,root}

sudo modprobe nbd
sudo qemu-nbd -c /dev/nbd0 -f qcow2 no-name-linux.qcow2

sudo parted --align minimal --script \
    /dev/nbd0 \
    mktable gpt \
    mkpart primary fat32 4MB 16MB \
    set 1 boot on \
    set 1 esp on \
    mkpart primary ext4 16MB 100% \
    print

sudo mkfs -t vfat /dev/nbd0p1
sudo mkfs -t ext4 /dev/nbd0p2
sudo mount /dev/nbd0p1 mnt-no-name-linux/efi
sudo mount /dev/nbd0p2 mnt-no-name-linux/root

sudo mkdir -p mnt-no-name-linux/efi/efi/boot/
sudo cp -v build/linux/arch/x86_64/boot/bzImage mnt-no-name-linux/efi/efi/boot/bootx64.efi
sudo cp -rv build/busybox/_install/* mnt-no-name-linux/root
sudo strip mnt-no-name-linux/root/bin/busybox

# add optional binaries
sudo cp -rv ./bin/* mnt-no-name-linux/root/bin

sudo umount /dev/nbd0p1
sudo umount /dev/nbd0p2

sudo qemu-nbd -d /dev/nbd0

qemu-img convert -f qcow2 -O vmdk no-name-linux.qcow2 no-name-linux.vmdk
qemu-img convert -f qcow2 -O vhdx no-name-linux.qcow2 no-name-linux.vhdx

cp /usr/share/OVMF/OVMF_VARS.fd OVMF_VARS.fd 

# nbdfuse mnt-no-name-linux/no-name-linux.raw [ qemu-nbd -f qcow2 no-name-linux.qcow2 ] &
# fusermount3 -u `realpath mnt-no-name-linux`

