#!/bin/bash

#    -nographic \
#    -kernel ~/build/linux/arch/x86/boot/bzImage \
#    -append "console=ttyAMA0 ro root=/dev/sda1 init=/sbin/init noinitrd nokaslr vt.handoff=1 oops=panic panic_on_warn=1 panic=-1 ftrace_dump_on_oops=orig_cpu debug earlyprintk=serial slub_debug=UZ" \


#    -vga std \
#    -display gtk \

# Can remove -kernel and -append to use grub.cfg

qemu-system-x86_64 \
    -vga std \
    -display gtk \
    -enable-kvm \
    -cpu host \
    -machine type=q35,accel=kvm \
    -smp 8 \
    -m 1G \
    -hda no-name-linux.img \
    -S -s & \
gdb -ex "add-auto-load-safe-path ~/src/linux/scripts/gdb/vmlinux-gdb.py" \
    -ex "file ~/build/linux/vmlinux" -ex 'target remote localhost:1234'
