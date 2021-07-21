    .section .init
    .globl _start
    .type _start,@function

_start:
	la sp, _sp

	/* Load data section */

	la a0, _data_lma
	la a1, _data
	la a2, _edata
	bgeu a1, a2, 2f

1:	lw t0, (a0)
	sw t0, (a1)
	addi a0, a0, 4
	addi a1, a1, 4
	bltu a1, a2, 1b

	/* Clear bss section */

2:	la a0, __bss_start
	la a1, _end
	bgeu a0, a1, 4f

3:	sw zero, (a0)
	addi a0, a0, 4
	bltu a0, a1, 3b

4:	call __libc_init_array
	call main

done:	j done

	.globl _init
_init:
    ret
