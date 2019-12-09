## Repacking initrd

1. Create a directory and switch into it:
```
# mkdir test
# cd test
```

2. Then uncompress and extract the initrd:

```
# zcat /boot/initrd.img | cpio -idmv
```

3. Edit the contents (if needed)

4. Finally repack and compress the initrd image:
```
# find . | cpio -o -c | gzip -9 > /boot/test.img
```

For image compressed with xz format, the below commands can be used to extract the initrd image.
```
# mkdir /tmp/initrd
# cd /tmp/initrd
# xz -dc < initrd.img | cpio --quiet -i --make-directories 
```

Repack and compress the initrd image:

# cd /tmp/initrd
# find . 2>/dev/null | cpio --quiet -c -o | xz -9 --format=lzma >"new_initrd.img"
