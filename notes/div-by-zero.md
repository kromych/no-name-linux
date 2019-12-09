```
IDT is at 0xfffffe0000000000

(gdb) x/16gx 0xfffffe0000000000
0xfffffe0000000000:	0x81a08e0000100b70	0x00000000ffffffff
0xfffffe0000000010:	0x81a08e0300100da0	0x00000000ffffffff
0xfffffe0000000020:	0x81a08e02001010f0	0x00000000ffffffff
0xfffffe0000000030:	0x81a0ee0000100df0	0x00000000ffffffff
0xfffffe0000000040:	0x81a0ee0000100b90	0x00000000ffffffff
0xfffffe0000000050:	0x81a08e0000100bb0	0x00000000ffffffff
0xfffffe0000000060:	0x81a08e0000100bd0	0x00000000ffffffff
0xfffffe0000000070:	0x81a08e0000100bf0	0x00000000ffffffff

(gdb) x/16i 0xffffffff81a00b70
   0xffffffff81a00b70 <divide_error>:	clac   
   0xffffffff81a00b73 <divide_error+3>:	pushq  $0xffffffffffffffff
   0xffffffff81a00b75 <divide_error+5>:	callq  0xffffffff81a00fe0 <error_entry>
   0xffffffff81a00b7a <divide_error+10>:	mov    %rsp,%rdi
   0xffffffff81a00b7d <divide_error+13>:	xor    %esi,%esi
   0xffffffff81a00b7f <divide_error+15>:	callq  0xffffffff8101a820 <do_divide_error>
   0xffffffff81a00b84 <divide_error+20>:	jmpq   0xffffffff81a010d0 <error_exit>
   0xffffffff81a00b89:	nopl   0x0(%rax)
   0xffffffff81a00b90 <overflow>:	clac   
   0xffffffff81a00b93 <overflow+3>:	pushq  $0xffffffffffffffff
   0xffffffff81a00b95 <overflow+5>:	callq  0xffffffff81a00fe0 <error_entry>
   0xffffffff81a00b9a <overflow+10>:	mov    %rsp,%rdi
   0xffffffff81a00b9d <overflow+13>:	xor    %esi,%esi
   0xffffffff81a00b9f <overflow+15>:	callq  0xffffffff8101a840 <do_overflow>
   0xffffffff81a00ba4 <overflow+20>:	jmpq   0xffffffff81a010d0 <error_exit>
   0xffffffff81a00ba9:	nopl   0x0(%rax)
```

```
int main()
{
    volatile int a = 0;
    volatile int b = 1/a;

    return 0;
}

gcc -o div-by-zero -O3 -no-pie div-by-zero.c
```

```
kromych@kromych-x1:~/src/linux/minimal/src/work$ objdump -S ./div-by-zero 

./div-by-zero:     file format elf64-x86-64
```

```
Disassembly of section .init:

0000000000401000 <_init>:
  401000:	48 83 ec 08          	sub    $0x8,%rsp
  401004:	48 8b 05 ed 2f 00 00 	mov    0x2fed(%rip),%rax        # 403ff8 <__gmon_start__>
  40100b:	48 85 c0             	test   %rax,%rax
  40100e:	74 02                	je     401012 <_init+0x12>
  401010:	ff d0                	callq  *%rax
  401012:	48 83 c4 08          	add    $0x8,%rsp
  401016:	c3                   	retq   

Disassembly of section .text:

0000000000401020 <main>:
  401020:	c7 44 24 f8 00 00 00 	movl   $0x0,-0x8(%rsp)
  401027:	00 
  401028:	b8 01 00 00 00       	mov    $0x1,%eax
  40102d:	8b 4c 24 f8          	mov    -0x8(%rsp),%ecx
  401031:	99                   	cltd   
  401032:	f7 f9                	idiv   %ecx
  401034:	89 44 24 fc          	mov    %eax,-0x4(%rsp)
  401038:	31 c0                	xor    %eax,%eax
  40103a:	c3                   	retq   
  40103b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
```

```
Breakpoint 1, do_signal (regs=0xffffc9000026ff58) at /home/kromych/src/linux/arch/x86/kernel/signal.c:813
813	{
(gdb) bt
#0  do_signal (regs=0xffffc9000026ff58) at /home/kromych/src/linux/arch/x86/kernel/signal.c:813
#1  0xffffffff81003c8e in exit_to_usermode_loop (regs=0xffffc9000026ff58, cached_flags=4) at /home/kromych/src/linux/arch/x86/entry/common.c:162
#2  0xffffffff8100419a in prepare_exit_to_usermode (regs=0xffffc9000026ff58) at /home/kromych/src/linux/arch/x86/entry/common.c:197
#3  0xffffffff81c009c5 in common_interrupt () at /home/kromych/src/linux/arch/x86/entry/entry_64.S:597
#4  0x0000000000000000 in ?? ()
```
