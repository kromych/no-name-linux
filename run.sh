#!/bin/bash

WAIT_DEBUG="-S -s"

GTK_OUTPUT="-vga std -display gtk"
SERIAL_KERN_OPTIONS="console=ttyS0"
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
    -drive if=none,format=qcow2,file=snapshots.qcow2 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=OVMF_VARS.fd,snapshot=on \
    -device virtio-scsi-pci,id=scsi0 \
    -device scsi-hd,drive=drive0,bus=scsi0.0,channel=0,scsi-id=0,lun=0 \
    -drive format=qcow2,file=no-name-linux.qcow2,if=none,id=drive0,snapshot=on \
#	  -loadvm save03 \
#   -snapshot \
