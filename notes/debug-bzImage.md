```
qemu-system-x86_64 -enable-kvm -cpu host -m 128M -kernel bzImage -initrd rootfs.cpio.gz -append "nokaslr" -S -s
```

```
gdb -ex "add-auto-load-safe-path /home/kromych/src/linux/scripts/gdb/vmlinux-gdb.py" -ex "file /home/kromych/build/linux/vmlinux" -ex 'target remote localhost:1234'
```

```
kromych@kromych-x1:~/src/linux/minimal/src/work$ echo ./div-by-zero | cpio -H newc -o | gzip >> rootfs.cpio.gz
33 blocks
```

```
kromych@kromych-x1:~/src/linux$ binwalk rootfs.cpio.gz 

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             gzip compressed data, from Unix, last modified: 2019-01-27 06:12:08
1511575       0x171097        gzip compressed data, from Unix, last modified: 2019-01-27 07:49:35
```
