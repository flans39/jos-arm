#include <inc/memlayout.h>

#define	RELOC(x) ((x) - KERNBASE)

// To keep this in the first portion of the binary.
.section ".text.boot"

// Make _start global.
.globl _start
_start = RELOC(entry)

// Entry point for the kernel.
.globl entry
entry:
	// Turn on MMU
	ldr r0, =(entry_pgdir - KERNBASE)
	mcr p15, 0, r0, c2, c0, 0
	mov r0, #0xFFFFFFFF
	mcr p15, 0, r0, c3, c0, 0
	mrc p15, 0, r0, c1, c0, 0
	orr r0, r0, #0x1
	mcr p15, 0, r0, c1, c0, 0

	// Setup the stack
	ldr sp, =bootstacktop

	// Clear out bss.
	ldr r4, =edata
	ldr r9, =end
	mov r5, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	b L2
L1:
	// store multiple at r4.
	stmia r4!, {r5-r8}
	// If we are still below bss_end, loop.
L2:
	cmp r4, r9
	blo L1

	//Jump up above KERNBASE before entering C code
	ldr lr, =relocated
	bx lr

relocated:
	// Call arm_init
	ldr r3, =arm_init
	blx r3

.data
// boot stack
	.p2align	12		// PGSHIFT
	.globl		bootstack
bootstack:
	.space		8*4096		// KSTKSIZE
	.globl		bootstacktop
bootstacktop:
