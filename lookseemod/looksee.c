#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kthread.h>
#include <linux/time.h>
#include <linux/timer.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/export.h>
#include <linux/smp.h>
#include <linux/jiffies.h>

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("kromych");
MODULE_DESCRIPTION("LookSee");
MODULE_VERSION("0.1");

#define ISAY "LOOKSEE:"

#define DUMP_CPU_DATA \
{\
    int smp_id = raw_smp_processor_id();\
    __u64 cr3 = 0; \
    __u64 cr8 = 0; \
    __u64 rflags = 0;\
    __u64 rsp = 0;\
\
    asm volatile (\
        "movq %%cr3, %%rax" \
        : "=a"(cr3)\
        : \
        : "memory"\
    );\
\
    asm volatile (\
        "movq %%cr8, %%rax" \
        : "=a"(cr8)\
        : \
        : "memory"\
    );\
\
    asm volatile (\
        "pushfq; popq %%rax" \
        : "=a"(rflags)\
        : \
        : "memory"\
    );\
\
    asm volatile (\
        "movq %%rsp, %%rax" \
        : "=a"(rsp)\
        : \
        : "memory"\
    );\
\
    printk(KERN_INFO ISAY "On CPU %u, cr3=0x%llx, cr8=%llx, rflags=0x%llx, rsp=0x%llx, interrupts enabled=%s", \
                            smp_id, cr3, cr8, rflags, rsp, (rflags & 0x0200) != 0 ? "true" : "false");\
}\


static void cpu_func(void* ParamPtr) 
{
    DUMP_CPU_DATA

    asm volatile (
        "movq $15, %%rax; movq %%rax, %%cr8; "
        :
        : 
        : "%rax", "memory"
    );

    __u64 i;
    for (i = 0; i < (1ULL << 32); ++i)
    {
        asm volatile ("pause" : : : "memory");
    }

    asm volatile (
        "movq $0, %%rax; movq %%rax, %%cr8; "
        :
        : 
        : "%rax", "memory"
    );
}

static int __init look_see_start(void)
{
    printk(KERN_INFO ISAY "Loading module...");

    DUMP_CPU_DATA    

    on_each_cpu(cpu_func, NULL, 0);

    return 0;
}

static void __exit look_see_end(void)
{
    printk(KERN_INFO ISAY "Unloaded");    
}

module_init(look_see_start);
module_exit(look_see_end);
