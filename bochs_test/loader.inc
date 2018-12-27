BaseOfLoader	        equ	    0x1000
OffsetOfLoader	        equ	    0x00
LoaderOrg               equ     BaseOfLoader << 4 + OffsetOfLoader ;=0x10000


;内核程序起始地址位于物理地址0x100000(1MB)处，因为1MB以下的物理地址并不会全是可用内存地址空间，这段物理地址被划分成为若干个子空间段。
;它们可以使内存空间、非内存空间以及地址空洞   书P56
;随着内核体积的不断增长，未来的内核程序很可能会超过1MB，因此让内核程序跳过这些纷繁复杂的内存空间，从平坦的1MB地址开始。
BaseOfKernel            equ     0x00
OffsetOfKernel          equ     0x100000
KernelOrg               equ     BaseOfKernel << 4 + OffsetOfKernel

;0x7E00是内核程序的临时转存空间，由于内核程序的读取操作是通过BIOS中断服务程序INT 13h实现，BIOS在实模式下只支持上限为1MB的物理地址空间寻址。
;所以必须先将内核程序读入到临时转存空间，然后在通过特殊方式搬运到1MB以上的内存空间中.
;完成搬运后这个临时转存空间就可以另作他用,此处将其改为内存结构数据的存储空间，供内核程序在初始化时使用.
BaseTmpOfKernel         equ     0x00
OffsetTmpOfKernel       equ     0x7E00
MemoryStructBufferAddr  equ	    0x7E00



%macro  macro_open_address_a20 0
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
%endmacro
