#!/bin/bash

######################################################
# 2.1. BUILD BUSYBOX
######################################################

BUILD_DIR=${PWD}/build
BUSYBOX_SRC=${PWD}/busybox
BUSYBOX_CONFIG=${PWD}/configs/busybox.config
BUSYBOX_BUILD=$BUILD_DIR/busybox
INITRAMFS=$BUILD_DIR/initramfs.cpio.gz

rm -rf $BUSYBOX_BUILD
mkdir -p $BUSYBOX_BUILD

cd $BUSYBOX_SRC

export KBUILD_OUTPUT=$BUSYBOX_BUILD
export KCONFIG_CONFIG=$BUSYBOX_CONFIG

make mrproper -j `nproc`

cp $KCONFIG_CONFIG $KBUILD_OUTPUT/.config

make -j `nproc`
make install

#####################################################
# 2.2. GENERATE ROOT FILESYSTEM
####################################################

mkdir -p $BUSYBOX_BUILD/_install/{dev,etc,proc,root,sys,tmp,var/run}
cd $BUSYBOX_BUILD/_install
chmod 1777 tmp

cat > etc/sysinit.sh << EOF
#/bin/sh

# Mount essentials
mount -t devtmpfs none /dev
mount -t devpts devpts /dev/pts
mount -t proc none /proc
mount -t sysfs none /sys

# Configure the logger
echo on > /proc/sys/kernel/printk_devkmsg
# Same as 'dmesg -n 8'
echo 8 > /proc/sys/kernel/printk

# Use polling
#setserial -a /dev/ttyS0 irq 0
#setserial -a /dev/ttyS1 irq 0
#setserial -a /dev/ttyS2 irq 0
#setserial -a /dev/ttyS3 irq 0

dmesg -n 7
EOF
chmod +x etc/sysinit.sh

cat > etc/inittab << EOF
::sysinit:/etc/sysinit.sh
::restart:/sbin/init
::respawn:/bin/cttyhack /bin/sh
#ttyS0::respawn:/sbin/getty -n -L ttyS0 115200 vt100
#ttyS1::respawn:/sbin/getty -n -L ttyS1 115200 vt100
EOF

cat > etc/group << EOF
root:!:0:root
EOF

cat > etc/passwd << EOF
root::0:0::/root:/bin/sh
EOF

sudo mknod dev/mem       c 1  1
sudo mknod dev/kmem      c 1  2
sudo mknod dev/null      c 1  3
sudo mknod dev/port      c 1  4
sudo mknod dev/zero      c 1  5
sudo mknod dev/full      c 1  7
sudo mknod dev/random    c 1  8
sudo mknod dev/urandom   c 1  9
sudo mknod dev/aio       c 1 10
sudo mknod dev/kmsg      c 1 11
sudo mknod dev/ttyS0     c 4 64
sudo mknod dev/ttyS1     c 4 65
sudo mknod dev/ttyS2     c 4 66
sudo mknod dev/ttyS3     c 4 67
sudo mknod dev/tty       c 5  0
sudo mknod dev/console   c 5  1
sudo mknod dev/ttyprintk c 5  3
sudo mknod dev/loop0     b 7  0
sudo mknod dev/loop1     b 7  1

mkdir dev/pts

sudo mknod dev/pts/ptmx c   5 2
sudo mknod dev/pts/0    c 136 0
sudo mknod dev/pts/1    c 136 1
sudo mknod dev/pts/2    c 136 2
sudo mknod dev/pts/3    c 136 3
sudo mknod dev/pts/4    c 136 4
sudo mknod dev/pts/5    c 136 5
sudo mknod dev/pts/6    c 136 6
sudo mknod dev/pts/7    c 136 7
sudo mknod dev/pts/8    c 136 8

#####################################################
# 2.3. ADD FILES TO /BIN
####################################################

cp ${BUILD_DIR}/bin/* bin/

#####################################################
# 2.4. GENERATE INIT RAM FS
####################################################

find . | cpio -o -H newc | gzip > ${INITRAMFS}
