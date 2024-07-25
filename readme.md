# No Name Linux

This repo helps to build and run the Linux kernel and busybox for the user land.
The scripts incorporate knowledge needed to facilitate ramping up on the Linux kernel 
debugging.

Also there is an example of building an out-of-tree kernel module [LookSee](./lookseemod/looksee.c)

> For `arm64`, please switch to the `arm64` branch.
> I'll merge it into `master` when I have time.

Eye candy:
1. Debugging Linux kernel
![Debugging Linux kernel](./notes/debug-graphic.png "Debugging Linux kernel")

2. Serial console, inspecting Local APIC for CPU 0 with QEMU
![Serial console](./notes/qemu-monitor-lapic.png "Serial console")

3. Debugging the ARM64 Linux kernel
![ARM64 Linux kernel](./notes/arm64-debug.png "ARM64 Linux kernel")

4. [What exactly happens inside the kernel when you divide by zero in your user-mode code](./notes/div-by-zero.md)

To clone:

```sh
git clone --recursive https://github.com/kromych/no-name-linux.git
```

To build the kernel:

```sh
./010-build-kernel.sh
```

To build the root filesystem:

```sh
./029-build-rootfs.sh 
```

To build the bootable image (you can also use it to boot a PC)

```sh
./091-mkimg-losetup.sh
```

To run:

```sh
./run.sh
```

To debug:

```sh
./run.sh waitdebug
```

and run `./attach-gdb.sh` in another console window/tab.

To supress graphic output, and run in the text mode:

```sh
./run.sh serial
```

In this case, you'll need to use `Ctrl+A` followed by `C` to QEMU's monitor.

If you want some binaries (statically linked) to go into the initrd, place
them under `./bin` in this repo.
