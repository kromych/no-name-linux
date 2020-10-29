## No Name Linux

This repo helps to build and run the Linux kernel and busybox for the user land.
The scripts incorporate knowledge needed to facilitate ramping up on the Linux kernel 
debugging.

Also there is an example of building an out-of-tree kernel module [LookSee](./lookseemod/looksee.c)

> For `arm64`, please switch to the `arm64` branch.
> I'll merge it into `master` when I have time.

> For Hyper-V, please switch to the hyper-v branch.
> I'll merge it into `master` when I have time.


Eye candy:
1. Debugging Linux kernel
![Debugging Linux kernel](./notes/debug-graphic.png "Debugging Linux kernel")

2. Serial console, inspecting Local APIC for CPU 0 with QEMU
![Serial console](./notes/qemu-monitor-lapic.png "Serial console")

3. Debugging the ARM64 Linux kernel
![ARM64 Linux kernel](./notes/arm64-debug.png "ARM64 Linux kernel")

4. [What exactly happens inside the kernel when you divide by zero in your user-mode code](./notes/div-by-zero.md)

5. Linux Kernel debugging under Hyper-V 
![Linux Kernel debugging under Hyper-V](./notes/hyper-v-kdbg.png)

To clone:
```sh
	git clone --recursive https://github.com/kromych/no-name-linux.git
```

To debug:

1. Build the root fs
2. Build the kernel
3. Create a VHDX virtual disk using the helper function in the powershell script
4. Create a Hyper-V Gen 2 VM with security boot disabled.
5. Add 2 serial ports to the VM:
```powershell
Set-VmComPort -Pipe \\.\pipe\Com1 -Number 1 -DebuggerMode Off
Set-VmComPort -Pipe \\.\pipe\Com2 -Number 2 -DebuggerMode Off    
```
6. Use ![npiperelay](https://github.com/jstarks/npiperelay) to setup kernel debugging relay
```sh
serial-relay //./pipe/Com2 kgdb &
```
7. Inside gdb,
```sh
target remote /dev/pts/3
```
8. Inside the Linux shell,
```sh
echo g > /proc/sysrq-trigger
```

9. For communicating over Hyper-V sockets, first need to register the integration service with
the port of choice:

```powershell
$PortNumber = 9999

$keyName = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\GuestCommunicationServices\"
$vsockTemplate = "{0:x8}-facb-11e6-bd58-64006a7986d3"
$newKey = New-Item -Path $keyName -Name ($vsockTemplate -f $PortNumber) -Force
New-ItemProperty -Path $newKey.PSPAth -Name "ElementName" -Value "Vsock port $PortNumber" -PropertyType "String"
```

To connect to a (h)vsock server (listening on port 9999):

```sh
socat - SOCKET-CONNECT:40:0:x00x00x0fx27x00x00x02x00x00x00x00x00x00x00
```

or

```sh
nc-vsock 2 9999
```

To start a vsock server inside the VM (port 9999):

```sh
# echo input
socat - SOCKET-LISTEN:40:0:x00x00x0fx27x00x00xffxffxffxffx00x00x00x00
```

or

```sh
# terminal over vsock
socat SOCKET-LISTEN:40:0:x00x00x0fx27x00x00xffxffxffxffx00x00x00x00,reuseaddr,fork EXEC:sh,pty,stderr,setsid,sigint,sane,ctty,echo=0
```

or

```sh
nc-vsock -l 9999
```

To connect to the server:

```powershell
hvc.exe <VM name> 9999
```

A primitive server running on Windows:
```c++
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <iphlpapi.h>
#include <hvsocket.h>
#include <stdio.h>

#pragma comment(lib, "Ws2_32.lib")

#pragma optimize("", off)

// Service ID must go under
// "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\GuestCommunicationServices"
// For Linux, the Hyper-V Socket Linux guest VSOCK template GUID is used with the port as the first
// part of the GUID

bool InitWinSock()
{
    WORD    versionRequested;
    WSADATA wsaData;
    int     err;

    versionRequested = MAKEWORD(2, 2);

    err = WSAStartup(versionRequested, &wsaData);
    if (err != 0)
    {
        printf("WSAStartup failed with error: %d\n", err);

        return false;
    }

    if (LOBYTE(wsaData.wVersion) != 2 || HIBYTE(wsaData.wVersion) != 2)
    {
        printf("Could not find a usable version of Winsock.dll\n");

        return false;
    }

    printf("The Winsock 2.2 dll was found okay\n");

    return true;
}

void DeinitWinSock()
{
    WSACleanup();
}

int RunServer(int VSockPort)
{
    SOCKADDR_HV sockAddr{};
    int         vsockPort{ VSockPort };
    SOCKET      sock{};
    int         retCode{};

    sock = socket(AF_HYPERV, SOCK_STREAM, HV_PROTOCOL_RAW);

    if (sock == INVALID_SOCKET)
    {
        printf("Winsock error: %d\n", WSAGetLastError());

        return 1;
    }

    sockAddr.Family = AF_HYPERV;
    sockAddr.Reserved = 0;
    sockAddr.VmId = HV_GUID_LOOPBACK; // HV_GUID_CHILDREN;
    sockAddr.ServiceId = HV_GUID_VSOCK_TEMPLATE;
    sockAddr.ServiceId.Data1 = vsockPort;

    retCode = bind(sock, (const struct sockaddr*)&sockAddr, sizeof(sockAddr));

    if (retCode != 0)
    {
        printf("Winsock error: %d\n", WSAGetLastError());

        return 1;
    }

    retCode = listen(sock, 0);

    if (retCode != 0)
    {
        printf("Winsock error: %d\n", WSAGetLastError());

        return 1;
    }

    for (;;)
    {
        SOCKADDR_HV peerAddr{};
        int         peerAddrSize{ sizeof(peerAddr) };
        SOCKET      peerSock{};

        char        buf[64]{};
        size_t      msgLen{};

        peerSock = accept(sock, (struct sockaddr*)&peerAddr, &peerAddrSize);

        if (peerSock == INVALID_SOCKET)
        {
            printf("Winsock error: %d\n", WSAGetLastError());

            return 1;
        }

        while ((msgLen = recv(peerSock, &buf[0], sizeof(buf), 0)) > 0)
        {
            printf("Received %zu bytes: %s\n", msgLen, buf);
        }

        closesocket(peerSock);
    }

    closesocket(sock);

    return 0;
}

int RunClient(const GUID& VmGuid, int VSockPort)
{
    SOCKADDR_HV sockAddr{};
    int         vsockPort{ VSockPort };
    SOCKET      sock{};
    int         retCode{};

    sock = socket(AF_HYPERV, SOCK_STREAM, HV_PROTOCOL_RAW);

    if (sock == INVALID_SOCKET)
    {
        printf("Winsock error: %d\n", WSAGetLastError());

        return 1;
    }

    sockAddr.Family = AF_HYPERV;
    sockAddr.Reserved = 0;
    sockAddr.VmId = HV_GUID_CHILDREN; // = __uuidof(gVmGuid); 
    sockAddr.ServiceId = HV_GUID_VSOCK_TEMPLATE;
    sockAddr.ServiceId.Data1 = vsockPort;

    retCode = connect(sock, (const struct sockaddr*)&sockAddr, sizeof(sockAddr));

    if (retCode != 0)
    {
        printf("Winsock error: %d\n", WSAGetLastError());

        return 1;
    }

    retCode = send(sock, "Hello, world!", 13, 0);

    if (retCode != 0)
    {
        printf("Winsock error: %d\n", WSAGetLastError());

        return 1;
    }

    closesocket(sock);

    return 0;
}

int main()
{
    struct __declspec(uuid("62fc7eb0-1f00-4231-ae6f-6e0c3995c4c4")) vmGuid {};

    if (!InitWinSock())
    {
        return 1;
    }

    RunServer(9999);
    //RunClient(__uuidof(vmGuid), 9999);

    DeinitWinSock();

    return 0;
}
```
