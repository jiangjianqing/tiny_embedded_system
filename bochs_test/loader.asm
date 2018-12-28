                %include "loader.inc"
                %include "bios_macros.inc"
org	LoaderOrg
                jmp     Label_Start

[section gdt]
LABEL_GDT:      dd      0,0
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
                macro_open_address_a20

;当前处于real mode（实模式），比如完成如下工作：
;a、读取kernel.bin,完成2件工作：1、将其读入到1MB空间内的内存区域；2、转存到1MB以上内存空间
;b、读取硬件信息，保存在内存指定空间中，便于kernel访问


;上述读取硬件信息的工作只有在实模式下使用bios才能进行访问，完成后即可切换到IA-32e模式，并跨段调转到kernel代码起始位置。
;从real mode（16位）切换到protect mode（32位）
;c、切换到IA-32e模式（64位）并跳转到kernel代码区


;=======	init IDT GDT goto protect mode 

	cli			;======close interrupt

	db	0x66
	lgdt	[GdtPtr]

;	db	0x66
;	lidt	[IDT_POINTER]

	mov	eax,	cr0
	or	eax,	1
	mov	cr0,	eax	

	jmp	dword SelectorCode32:GO_TO_TMP_Protect

[SECTION .s32]
[BITS 32]

GO_TO_TMP_Protect:

;=======	go to tmp long mode

	mov	ax,	0x10
	mov	ds,	ax
	mov	es,	ax
	mov	fs,	ax
	mov	ss,	ax
	mov	esp,	7E00h

	call	support_long_mode
	test	eax,	eax

	jz	no_support

;=======	init temporary page table 0x90000

	mov	dword	[0x90000],	0x91007
	mov	dword	[0x90800],	0x91007		

	mov	dword	[0x91000],	0x92007

	mov	dword	[0x92000],	0x000083

	mov	dword	[0x92008],	0x200083

	mov	dword	[0x92010],	0x400083

	mov	dword	[0x92018],	0x600083

	mov	dword	[0x92020],	0x800083

	mov	dword	[0x92028],	0xa00083

;=======	load GDTR64

	db	0x66
	lgdt	[Gdt64Ptr]
	mov	ax,	0x10
	mov	ds,	ax
	mov	es,	ax
	mov	fs,	ax
	mov	gs,	ax
	mov	ss,	ax

	mov	esp,	7E00h

;=======	open PAE

	mov	eax,	cr4
	bts	eax,	5
	mov	cr4,	eax

;=======	load	cr3 ,fill with temporary page table address

	mov	eax,	0x90000
	mov	cr3,	eax

;=======	enable long-mode

	mov	ecx,	0C0000080h		;IA32_EFER
	rdmsr

	bts	eax,	8
	wrmsr

;=======	open PE and paging

	mov	eax,	cr0
	bts	eax,	0
	bts	eax,	31
	mov	cr0,	eax

;=======至此cpu进入IA-32e模式，但是处理器目前正在执行保护模式的程序，这种状态叫做兼容模式，即运行在IA-32e模式下的32位程序模式。
;=======若想真正运行在IA-32e模式下，还需要一条跨段跳转/调用指令将CS段寄存器的值更新为IA-32e模式的代码段，即跳转到kernel.bin所在的内存地址即可
    ;加载kernel.bin进入内存后才可以使用下面的跨段跳转,跳转之后cpu将正式进入IA-32e模式
	jmp	SelectorCode64:OffsetOfKernel


;=======	no support
no_support:

	            jmp	$


;=======	test support long mode or not

support_long_mode:

	            mov	eax,	0x80000000
	            cpuid
	            cmp	eax,	0x80000001
	            setnb	al	
	            jb	support_long_mode_done
	            mov	eax,	0x80000001
	            cpuid
	            bt	edx,	29
	            setc	al
support_long_mode_done:
	
	            movzx	eax,	al
	            ret


;=======	display messages

StartLoaderMessage:	db	"Start Loader"
StartLoaderMessageLen   equ $-StartLoaderMessage





