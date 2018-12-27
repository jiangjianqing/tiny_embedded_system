                %include "loader.inc"
                %include "bios_macros.inc"
org	LoaderOrg
                jmp     Label_Start

[section gdt]
LABEL_GDT:      dw      0,0
LABEL_DESC_CODE32:	
                dd	    0x0000FFFF,0x00CF9A00
LABEL_DESC_DATA32:	
                dd	    0x0000FFFF,0x00CF9200
GdtLen          equ     $-LABEL_GDT
GdtPtr:         dw      GdtLen - 1
                dd      LABEL_GDT
SelectorCode32  equ     LABEL_DESC_CODE32 - LABEL_GDT
SelectorData32  equ     LABEL_DESC_DATA32 - LABEL_GDT

[section gdt64]
LABEL_GDT64:		dq	0x0000000000000000
LABEL_DESC_CODE64:	dq	0x0020980000000000
LABEL_DESC_DATA64:	dq	0x0000920000000000

Gdt64Len        equ     $ - LABEL_GDT64
Gdt64Ptr        dw      Gdt64Len - 1
                dd      LABEL_GDT64

SelectorCode64	equ	LABEL_DESC_CODE64 - LABEL_GDT64
SelectorData64	equ	LABEL_DESC_DATA64 - LABEL_GDT64

[SECTION .s16]
[BITS 16]
Label_Start:
	            mov	    ax,	cs
	            mov	    ds,	ax
	            mov	    es,	ax
	            mov	    ax,	0x00
	            mov	    ss,	ax
	            mov	    sp,	0x7c00  ;0x7c00是BIOS跳转至boot程序的位置，这里算是复用了那段空间

;=======	display on screen : Start Loader......
                macro_screen_cursor_set_pos 2,0
                macro_screen_print   StartLoaderMessage , StartLoaderMessageLen

;=======	open address A20
	push	ax
	in	al,	92h
	or	al,	00000010b
	out	92h,	al
	pop	ax

	cli

	db	0x66
	lgdt	[GdtPtr]	

	mov	eax,	cr0
	or	eax,	1
	mov	cr0,	eax

	mov	ax,	SelectorData32
	mov	fs,	ax
	mov	eax,	cr0
	and	al,	11111110b
	mov	cr0,	eax

	sti


	            jmp	$

;=======	display messages

StartLoaderMessage:	db	"Start Loader baby"
StartLoaderMessageLen   equ $-StartLoaderMessage





