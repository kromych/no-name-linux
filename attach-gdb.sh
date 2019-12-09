#!/bin/bash

# Ctrl+A followed by C gives access to the monitor (-nographic)

gdb -ex "add-auto-load-safe-path ./linux/scripts/gdb/vmlinux-gdb.py" \
    -ex "file ./build/linux/vmlinux" -ex 'target remote localhost:1234'
