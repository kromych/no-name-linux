#!/bin/bash

# Can use -kernel and -append (grub.cfg makes no snse in that case)

# -fsdev local,id=r,path=${PWD}/rootfs-arm64/,security_model=none \

WAIT_DEBUG="-S -s"

GTK_OUTPUT="-vga std -display gtk"
SERIAL_KERN_OPTIONS="ro console=ttyAMA0 nokaslr oops=panic panic_on_warn=0 panic=0 ftrace_dump_on_oops=orig_cpu debug earlyprintk=serial"
SERIAL_OUTPUT="-nographic -serial mon:stdio -kernel ./build/linux-arm64/arch/arm64/boot/Image"

DEBUG=""
KERN_OPTIONS="${SERIAL_KERN_OPTIONS}"
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
    -fsdev local,id=r,path=${PWD}/rootfs-arm64/,security_model=none \
    -cpu cortex-a57 \
    -machine virt \
    -smp 1 \
    -m 1G 
