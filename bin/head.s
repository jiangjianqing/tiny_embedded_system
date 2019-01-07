# 1 "head.S"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
/* Copyright (C) 1991-2018 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */




/* This header is separate from features.h so that the compiler can
   include it implicitly at the start of every compilation.  It must
   not itself include <features.h> or any other header that includes
   <features.h> because the implicit include comes before any feature
   test macros that may be defined in a source file before it first
   explicitly includes a system header.  GCC knows the name of this
   header in order to preinclude it.  */

/* glibc's intent is to support the IEC 559 math functionality, real
   and complex.  If the GCC (4.9 and later) predefined macros
   specifying compiler intent are available, use them to determine
   whether the overall intent is to support these features; otherwise,
   presume an older compiler has intent to support these features and
   define these macros by default.  */
# 52 "/usr/include/stdc-predef.h" 3 4
/* wchar_t uses Unicode 10.0.0.  Version 10.0 of the Unicode Standard is
   synchronized with ISO/IEC 10646:2017, fifth edition, plus
   the following additions from Amendment 1 to the fifth edition:
   - 56 emoji characters
   - 285 hentaigana
   - 3 additional Zanabazar Square characters */


/* We do not support C11 <threads.h>.  */
# 32 "<command-line>" 2
# 1 "head.S"
/***************************************************
*		版权声明
*
*	本操作系统名为：MINE
*	该操作系统未经授权不得以盈利或非盈利为目的进行开发，
*	只允许个人学习以及公开交流使用
*
*	代码最终所有权及解释权归田宇所有；
*
*	本模块作者：	田宇
*	EMail:		345538255@qq.com
*
*
***************************************************/

.section .text

.globl _start

_start:

 mov $0x10, %ax
 mov %ax, %ds
 mov %ax, %es
 mov %ax, %fs
 mov %ax, %ss
 mov $0x7E00, %esp

//=======	load GDTR

 lgdt GDT_POINTER(%rip)

//=======	load	IDTR

 lidt IDT_POINTER(%rip)

 mov $0x10, %ax
 mov %ax, %ds
 mov %ax, %es
 mov %ax, %fs
 mov %ax, %gs
 mov %ax, %ss

 movq $0x7E00, %rsp

//=======	load	cr3

 movq $0x101000, %rax
 movq %rax, %cr3
 movq switch_seg(%rip), %rax
 pushq $0x08
 pushq %rax
 lretq

//=======	64-bit mode code

switch_seg:
 .quad entry64

entry64:
 movq $0x10, %rax
 movq %rax, %ds
 movq %rax, %es
 movq %rax, %gs
 movq %rax, %ss
 movq $0xffff800000007E00, %rsp /* rsp address */

 movq go_to_kernel(%rip), %rax /* movq address */
 pushq $0x08
 pushq %rax
 lretq

go_to_kernel:
 .quad Start_Kernel

//=======	init page
.align 8

.org 0x1000

__PML4E:

 .quad 0x102007
 .fill 255,8,0
 .quad 0x102007
 .fill 255,8,0

.org 0x2000

__PDPTE:

 .quad 0x103003
 .fill 511,8,0

.org 0x3000

__PDE:

 .quad 0x000083
 .quad 0x200083
 .quad 0x400083
 .quad 0x600083
 .quad 0x800083
 .quad 0xe0000083 /*0x a00000*/
 .quad 0xe0200083
 .quad 0xe0400083
 .quad 0xe0600083
 .quad 0xe0800083 /*0x1000000*/
 .quad 0xe0a00083
 .quad 0xe0c00083
 .quad 0xe0e00083
 .fill 499,8,0

//=======	GDT_Table

.section .data

.globl GDT_Table

GDT_Table:
 .quad 0x0000000000000000 /*0	NULL descriptor		       	00*/
 .quad 0x0020980000000000 /*1	KERNEL	Code	64-bit	Segment	08*/
 .quad 0x0000920000000000 /*2	KERNEL	Data	64-bit	Segment	10*/
 .quad 0x0020f80000000000 /*3	USER	Code	64-bit	Segment	18*/
 .quad 0x0000f20000000000 /*4	USER	Data	64-bit	Segment	20*/
 .quad 0x00cf9a000000ffff /*5	KERNEL	Code	32-bit	Segment	28*/
 .quad 0x00cf92000000ffff /*6	KERNEL	Data	32-bit	Segment	30*/
 .fill 10,8,0 /*8 ~ 9	TSS (jmp one segment <7>) in long-mode 128-bit 40*/
GDT_END:

GDT_POINTER:
GDT_LIMIT: .word GDT_END - GDT_Table - 1
GDT_BASE: .quad GDT_Table

//=======	IDT_Table

.globl IDT_Table

IDT_Table:
 .fill 512,8,0
IDT_END:

IDT_POINTER:
IDT_LIMIT: .word IDT_END - IDT_Table - 1
IDT_BASE: .quad IDT_Table

//=======	TSS64_Table

.globl TSS64_Table

TSS64_Table:
 .fill 13,8,0
TSS64_END:

TSS64_POINTER:
TSS64_LIMIT: .word TSS64_END - TSS64_Table - 1
TSS64_BASE: .quad TSS64_Table
