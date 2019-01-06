                %include "loader.inc"
                %include "bios_macros.inc"
                %include "loader_read_kernel.inc"
org	LoaderOrg
                jmp     Label_Start

[section gdt]
LABEL_GDT:      dd      0,0                         ;NULL段描述符 , 段选择子index = 0
LABEL_DESC_CODE32:	
                dd	    0x0000FFFF,0x00CF9A00   ;段选择子index = 1
LABEL_DESC_DATA32:	
                dd	    0x0000FFFF,0x00CF9200
GdtLen          equ     $-LABEL_GDT
GdtPtr:         dw      GdtLen - 1                  ;GDTR_Limit
                dd      LABEL_GDT
SelectorCode32  equ     8;LABEL_DESC_CODE32 - LABEL_GDT   ;= 1<<3 + 0<<2 + 0  ,含义 : 1=index,TI=0=GDT ,RPL=0
SelectorData32  equ     LABEL_DESC_DATA32 - LABEL_GDT

[section gdt64]
LABEL_GDT64:		dq	0x0000000000000000
LABEL_DESC_CODE64:	dq	0x0020980000000000
LABEL_DESC_DATA64:	dq	0x0000920000000000

Gdt64Len        equ     $ - LABEL_GDT64
Gdt64Ptr        dw      Gdt64Len - 1                ;GDTR_Limit
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
;=======	reset floppy

	xor	ah,	ah
	xor	dl,	dl
	int	13h
                macro_read_kernel

;上述读取硬件信息的工作只有在实模式下使用bios才能进行访问，完成后即可切换到IA-32e模式，并跨段调转到kernel代码起始位置。
;从real mode（16位）切换到protect mode（32位）
;c、切换到IA-32e模式（64位）并跳转到kernel代码区


;=======	init IDT GDT goto protect mode 

	cli			;======close interrupt

	db	0x66
	lgdt	[GdtPtr]

;	db	0x66
;	lidt	[IDT_POINTER]

    ;open PE , 处理器要求只能在开启分页机制的保护模式下才可以切换到IA-32e模式
	mov	eax,	cr0
	;or	eax,	1       ;enable PE 的另一种写法
    bts eax,0           ;enable PE
    ;bts eax,31          ;enable PG ,如果开启分页机制，那么mov cr0指令和JMP/CALL指令必须位于同一性地址映射的页面内。书P68 ,而开启IA-32e的第一步就是需要复位PG标志位，所以直接不开启，简化步骤。
	mov	cr0,	eax	    ;cr0设置结束后，必须紧跟一条远跳转(far JMP)/远调用(far CALL)指令，以切换到保护模式的代码中去执行（典型的保护模式切换方法） 书P68
	jmp	dword SelectorCode32:GO_TO_TMP_Protect

[SECTION .s32]
[BITS 32]

GO_TO_TMP_Protect:

;=======	go to tmp long mode,进入保护模式后，处理器将从0特权级(CPL = 0)开始执行

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
	mov	ax,	0x10        ;0x10是IA-32e模式的段描述符，并不是一个随意的数字
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
	bts	eax,	0       ;enable PE
	bts	eax,	31      ;enable PG
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



;临时处理
    ;=======	read one sector from floppy

    Func_ReadOneSector:
	    
	    push	bp
	    mov	bp,	sp
	    sub	esp,	2
	    mov	byte	[bp - 2],	cl
	    push	bx
	    mov	bl,	[BPB_SecPerTrk]
	    div	bl
	    inc	ah
	    mov	cl,	ah
	    mov	dh,	al
	    shr	al,	1
	    mov	ch,	al
	    and	dh,	1
	    pop	bx
	    mov	dl,	[BS_DrvNum]
    Label_Go_On_Reading:
	    mov	ah,	2
	    mov	al,	byte	[bp - 2]
	    int	13h
	    jc	Label_Go_On_Reading
	    add	esp,	2
	    pop	bp
	    ret

    ;=======	get FAT Entry

    Func_GetFATEntry:

	    push	es
	    push	bx
	    push	ax
	    mov	ax,	00
	    mov	es,	ax
	    pop	ax
	    mov	byte	[Odd],	0
	    mov	bx,	3
	    mul	bx
	    mov	bx,	2
	    div	bx
	    cmp	dx,	0
	    jz	Label_Even
	    mov	byte	[Odd],	1

    Label_Even:

	    xor	dx,	dx
	    mov	bx,	[BPB_BytesPerSec]
	    div	bx
	    push	dx
	    mov	bx,	8000h
	    add	ax,	SectorNumOfFAT1Start
	    mov	cl,	2
	    call	Func_ReadOneSector
	    
	    pop	dx
	    add	bx,	dx
	    mov	ax,	[es:bx]
	    cmp	byte	[Odd],	1
	    jnz	Label_Even_2
	    shr	ax,	4

    Label_Even_2:
	    and	ax,	0fffh
	    pop	bx
	    pop	es
	    ret

;=======	tmp variable

RootDirSizeForLoop	dw	RootDirSectors
SectorNo		dw	0
Odd			db	0
OffsetOfKernelFileCount	dd	OffsetOfKernel

	BPB_SecPerTrk	dw	18
	BPB_NumHeads	dw	2
	BPB_hiddSec	dd	0
	BPB_TotSec32	dd	0
	BS_DrvNum	db	0
    BPB_BytesPerSec	dw	512

MemStructNumber		dd	0

SVGAModeCounter		dd	0

DisplayPosition		dd	0

;=======	display messages

StartLoaderMessage:	db	"Start Loader"
StartLoaderMessageLen   equ $-StartLoaderMessage

NoLoaderMessage:	db	"ERROR:No KERNEL Found"
KernelFileName:		db	"KERNEL  BIN",0



