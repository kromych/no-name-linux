#!/bin/bash

######################################################
# 2.1. BUILD BUSYBOX
######################################################

NUM_JOBS=16

BUSYBOX_SRC=${PWD}/busybox
BUSYBOX_CONFIG=${PWD}/busybox.config
INITRAMFS=${PWD}/build/initramfs-arm64.cpio.gz

export KBUILD_OUTPUT=${PWD}/build/busybox-arm64

cd $BUSYBOX_SRC
make mrproper

rm -rf $KBUILD_OUTPUT
mkdir -p $KBUILD_OUTPUT

HOST_ARCH=$(uname -m)

# Check if a target architecture is provided as an argument
TARGET_ARCH=${1:-$HOST_ARCH}

if [ "$HOST_ARCH" != "$TARGET_ARCH" ]; then
    CROSS_COMPILE=${TARGET_ARCH}-linux-gnu-
fi

case "$TARGET_ARCH" in
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

cp $BUSYBOX_CONFIG $KBUILD_OUTPUT/.config

ARCH=$KTARGET_ARCH CROSS_COMPILE=$CROSS_COMPILE make -j $NUM_JOBS
ARCH=$KTARGET_ARCH CROSS_COMPILE=$CROSS_COMPILE make -j $NUM_JOBS install

#####################################################
# 2.2. GENERATE ROOT FILESYSTEM
####################################################

cd $KBUILD_OUTPUT/_install

mkdir dev
mkdir etc
mkdir proc
mkdir root
mkdir src
mkdir sys
mkdir tmp
mkdir -p var/run
chmod 1777 tmp

cat > etc/bootscript.sh << EOF
#!/bin/sh

dmesg -n 1
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys
ip link set lo up
ip link set eth0 up
udhcpc -b -i eth0 -s /etc/rc.dhcp
EOF
chmod +x etc/bootscript.sh

cat > etc/rc.dhcp << EOF
#!/bin/sh

ip addr add \$ip/\$mask dev \$interface
if [ -n "$router"]; then
  ip route add default via \$router dev \$interface
fi
EOF
chmod +x etc/rc.dhcp

cat > etc/welcome.txt << EOF
Welcome to The No Name Linux!
EOF

cat > etc/inittab << EOF
::sysinit:/etc/bootscript.sh
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::once:cat /etc/welcome.txt
::respawn:/bin/cttyhack /bin/sh
tty2::once:cat /etc/welcome.txt
tty2::respawn:/bin/sh
tty3::once:cat /etc/welcome.txt
tty3::respawn:/bin/sh
tty4::once:cat /etc/welcome.txt
tty4::respawn:/bin/sh
EOF

find . | cpio -o -H newc | gzip > ${INITRAMFS}
