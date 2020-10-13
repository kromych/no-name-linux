#/bin/bash

exec socat PTY,link="./con" SYSTEM:"while npiperelay.exe -p -ei //./pipe/PicoLin-com1; do true; done" &
exec socat PTY,link="./gdb" SYSTEM:"while npiperelay.exe -p -ei //./pipe/PicoLin-com2; do true; done" &
