#!/bin/bash

# Can use -kernel and -append (grub.cfg makes no snse in that case)

# -fsdev local,id=r,path=${PWD}/rootfs-arm64/,security_model=none \

WAIT_DEBUG="-S -s"

GTK_OUTPUT="-vga std -display gtk"
SERIAL_KERN_OPTIONS="ro console=ttyAMA0 root=/dev/vda init=/sbin/init noinitrd nokaslr vt.handoff=1 oops=panic panic_on_warn=1 panic=-1 ftrace_dump_on_oops=orig_cpu debug earlyprintk=serial slub_debug=UZ"
SERIAL_OUTPUT="-nographic -serial mon:stdio -kernel ./build/linux/arch/arm64/boot/Image"

DEBUG=""
KERN_OPTIONS="SERIAL_KERN_OPTIONS"
OUTPUT=${SERIAL_OUTPUT}

for argval in "$@"
do
  case $argval in
    waitdebug) 
        DEBUG=${WAIT_DEBUG}
    ;;
    serial) 
        OUTPUT=${SERIAL_OUTPUT}
        KERN_OPTIONS=${SERIAL_KERN_OPTIONS}
    ;;
  esac
done

qemu-system-aarch64 \
    ${OUTPUT} \
    ${DEBUG} \
    -append "$KERN_OPTIONS" \
    -cpu cortex-a57 \
    -machine virt \
    -smp 1 \
    -m 1G \
    -drive if=none,file=${PWD}/no-name-linux-arm64.img,format=raw,id=hd \
    -device virtio-blk-pci,drive=hd
