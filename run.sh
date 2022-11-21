#!/bin/bash

WAIT_DEBUG="-S -s"

GTK_OUTPUT="-vga std -display gtk"
SERIAL_KERN_OPTIONS="console=ttyS0 root=/dev/sda2 init=/sbin/init noinitrd nokaslr vt.handoff=1 oops=panic panic_on_warn=1 panic=-1 ftrace_dump_on_oops=orig_cpu debug earlyprintk=serial slub_debug=UZ"
#SERIAL_OUTPUT="-nographic -serial mon:stdio -kernel ./build/linux/arch/x86/boot/bzImage"
SERIAL_OUTPUT="-nographic -chardev stdio,id=char0,mux=on,logfile=serial.log,signal=off \
  -serial chardev:char0 -mon chardev=char0 -kernel ./build/linux/arch/x86/boot/bzImage"

DEBUG=""
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
    -smp 8 \
    -m 1G \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=OVMF_VARS.fd,snapshot=on \
    -drive format=qcow2,file=no-name-linux.qcow2,snapshot=on \