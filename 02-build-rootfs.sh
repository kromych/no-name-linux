#!/bin/bash

######################################################
# 2.1. BUILD BUSYBOX
######################################################

GRUB_CFG=${PWD}/grub.cfg
ROOTFS=${PWD}/rootfs
BUSYBOX_SRC=${PWD}/busybox
BUSYBOX_CONFIG=${PWD}/busybox.config

KERNEL=${PWD}/build/linux/arch/x86_64/boot/bzImage

export KBUILD_OUTPUT=${PWD}/build/busybox

cd $BUSYBOX_SRC
make mrproper

rm -rf $KBUILD_OUTPUT
mkdir -p $KBUILD_OUTPUT

make defconfig

cp $BUSYBOX_CONFIG $KBUILD_OUTPUT/.config

make -j 16
make install

#####################################################
# 2.2. GENERATE ROOT FILESYSTEM
####################################################

cd $KBUILD_OUTPUT/_install

mkdir -p boot/grub

mkdir dev
mkdir etc
mkdir proc
mkdir root
mkdir src
mkdir sys
mkdir tmp
mkdir -p var/run
chmod 1777 tmp

cp ${GRUB_CFG} ./boot/grub
cp ${KERNEL} .

# cat > init.c << EOF
# 
# int _start()
# {
#     for(;;)
#     {
#         asm volatile("pause");
#     }
# 
#     return 0;
# }
# 
# EOF
#gcc -o init -ffreestanding -nostdlib -nostdinc -no-pie init.c 

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

# Copy to the target dir

rm -rf ${ROOTFS}
mkdir ${ROOTFS}

cp -r ./* ${ROOTFS}
