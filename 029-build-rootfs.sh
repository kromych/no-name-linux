#!/bin/bash

######################################################
# 2.1. BUILD BUSYBOX
######################################################

ROOTFS=${PWD}/rootfs
DROPBEAR_BUILD=${PWD}/build/dropbear
BUSYBOX_SRC=${PWD}/busybox
BUSYBOX_CONFIG=${PWD}/configs/busybox.config

KERNEL=${PWD}/build/linux/arch/x86_64/boot/bzImage

export KBUILD_OUTPUT=${PWD}/build/busybox

cd $BUSYBOX_SRC
make mrproper

rm -rf $KBUILD_OUTPUT
mkdir -p $KBUILD_OUTPUT/_install

make defconfig

cp $BUSYBOX_CONFIG $KBUILD_OUTPUT/.config

make -j `nproc`
make -j `nproc` install

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

dmesg -n 7
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys
mount -o remount,rw /dev/root
sysctl -w kernel.core_pattern=core.%e.%p
sysctl -w kernel.core_pipe_limit=1
ulimit -c unlimited
ulimit -a
EOF
chmod +x etc/bootscript.sh

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

cat > etc/group << EOF
root:!:0:root
EOF

cat > etc/passwd << EOF
root::0:0::/root:/bin/sh
EOF

# Copy to the target dir

rm -rf ${ROOTFS}
mkdir ${ROOTFS}

cp -r ./* ${ROOTFS}
