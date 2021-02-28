#!/bin/bash

# Can use -kernel and -append (grub.cfg makes no snse in that case)

WAIT_DEBUG="-S"

GTK_OUTPUT="-vga std -display gtk"
SERIAL_KERN_OPTIONS="earlyprintk=serial slub_debug=UZ"
SERIAL_OUTPUT="-nographic -serial mon:stdio -kernel ./build/linux/arch/x86/boot/bzImage"

DEBUG="-s"
KERN_OPTIONS=""
OUTPUT=${GTK_OUTPUT}

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

qemu-system-x86_64 \
    ${OUTPUT} \
    ${DEBUG} \
    -append "$KERN_OPTIONS" \
    -enable-kvm \
    -cpu host \
    -machine type=q35,accel=kvm \
    -smp 4 \
    -m 1G
