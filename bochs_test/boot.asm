;/***************************************************
;		版权声明
;
;	本操作系统名为：MINE
;	该操作系统未经授权不得以盈利或非盈利为目的进行开发，
;	只允许个人学习以及公开交流使用
;
;	代码最终所有权及解释权归田宇所有；
;
;	本模块作者：	田宇
;	EMail:		345538255@qq.com
;
;
;***************************************************/

%define         BIOS_START_ADDRESS      0x7c00
%xdefine        BASE_OF_STACK           BIOS_START_ADDRESS

%macro macro_begin_bios 0
;将程序的起始地址设置在0x7c00处，至于为什么是0x7c00，只有当年的bios工程师才会知道
                org                     BIOS_START_ADDRESS

BaseOfStack	    equ	                    BASE_OF_STACK

%endmacro

%macro macro_end_bios 0
;=======	fill zero until whole sector

	            times	510 - ($ - $$)	db	0
	            dw	    0xaa55
%endmacro

;----------以下为正式代码--------------


                macro_begin_bios

                jmp     Label_Start

StartBootMessage:	
                db	"Start Boot"
StartBootMessageLen equ $-StartBootMessage

Label_Start:

	            mov	    ax,	cs
	            mov	    ds,	ax
	            mov	    es,	ax
	            mov	    ss,	ax
	            mov	    sp,	BASE_OF_STACK

;=======	clear screen

	mov	ax,	0600h
	mov	bx,	0700h
	mov	cx,	0
	mov	dx,	0184fh
	int	10h

;=======	set focus

	mov	ax,	0200h
	mov	bx,	0000h
	mov	dx,	0000h
	int	10h

;=======	display on screen : Start Booting......

	mov	ax,	1301h
	mov	bx,	000fh
	mov	dx,	0000h
	mov	cx,	StartBootMessageLen
	push	ax
	mov	ax,	ds
	mov	es,	ax
	pop	ax
	mov	bp,	StartBootMessage
	int	10h

;=======	reset floppy

	xor	ah,	ah
	xor	dl,	dl
	int	13h


;代码停在此处
	jmp	$


;-------填充剩余空间------
                macro_end_bios

