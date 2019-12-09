```
git submodule add https://github.com/torvalds/linux.git
git submodule add https://github.com/mirror/busybox.git

git submodule init
git submodule update

git status

cd linux
git reset --hard v5.4
cd ..

cd busybox
git reset --hard 1_29_3
cd ..

git commit -a

git submodule status
```