%ifndef LOADER_READ_KERNEL_MACROS_INC 
%define LOADER_READ_KERNEL_MACROS_INC

                %include "fat12_macros.inc"

%macro      macro_read_kernel 0

;=======	search kernel.bin
	mov	word	[SectorNo],	SectorNumOfRootDirStart

Lable_Search_In_Root_Dir_Begin:

	cmp	word	[RootDirSizeForLoop],	0
	jz	Label_No_LoaderBin
	dec	word	[RootDirSizeForLoop]	
	mov	ax,	00h
	mov	es,	ax
	mov	bx,	8000h
	mov	ax,	[SectorNo]
	mov	cl,	1
	call	Func_ReadOneSector
	mov	si,	KernelFileName
	mov	di,	8000h
	cld
	mov	dx,	10h

	
Label_Search_For_LoaderBin:

	cmp	dx,	0
	jz	Label_Goto_Next_Sector_In_Root_Dir
	dec	dx
	mov	cx,	11

Label_Cmp_FileName:

	cmp	cx,	0
	jz	Label_FileName_Found
	dec	cx
	lodsb	
	cmp	al,	byte	[es:di]
	jz	Label_Go_On
	jmp	Label_Different

Label_Go_On:
	
	inc	di
	jmp	Label_Cmp_FileName

Label_Different:

	and	di,	0FFE0h
	add	di,	20h
	mov	si,	KernelFileName
	jmp	Label_Search_For_LoaderBin

Label_Goto_Next_Sector_In_Root_Dir:
	
	add	word	[SectorNo],	1
	jmp	Lable_Search_In_Root_Dir_Begin
	
;=======	display on screen : ERROR:No KERNEL Found

Label_No_LoaderBin:

	mov	ax,	1301h
	mov	bx,	008Ch
	mov	dx,	0300h		;row 3
	mov	cx,	21
	push	ax
	mov	ax,	ds
	mov	es,	ax
	pop	ax
	mov	bp,	NoLoaderMessage
	int	10h
	jmp	$

;=======	found loader.bin name in root director struct

Label_FileName_Found:
	mov	ax,	RootDirSectors
	and	di,	0FFE0h
	add	di,	01Ah
	mov	cx,	word	[es:di]
	push	cx
	add	cx,	ax
	add	cx,	SectorBalance
	mov	eax,	BaseTmpOfKernel;BaseOfKernelFile
	mov	es,	eax
	mov	bx,	OffsetTmpOfKernel;OffsetOfKernelFile
	mov	ax,	cx


Label_Go_On_Loading_File:
	push	ax
	push	bx
	mov	ah,	0Eh
	mov	al,	'.'
	mov	bl,	0Fh
	int	10h
	pop	bx
	pop	ax

	mov	cl,	1
	call	Func_ReadOneSector
	pop	ax

;;;;;;;;;;;;;;;;;;;;;;;	
	push	cx
	push	eax
	push	fs
	push	edi
	push	ds
	push	esi

	mov	cx,	200h
	mov	ax,	BaseOfKernel
	mov	fs,	ax
	mov	edi,	dword	[OffsetOfKernelFileCount]

	mov	ax,	BaseTmpOfKernel
	mov	ds,	ax
	mov	esi,	OffsetTmpOfKernel

Label_Mov_Kernel:	;------------------
	
	mov	al,	byte	[ds:esi]
	mov	byte	[fs:edi],	al

	inc	esi
	inc	edi

	loop	Label_Mov_Kernel

	mov	eax,	0x1000
	mov	ds,	eax

	mov	dword	[OffsetOfKernelFileCount],	edi

	pop	esi
	pop	ds
	pop	edi
	pop	fs
	pop	eax
	pop	cx
;;;;;;;;;;;;;;;;;;;;;;;	

	call	Func_GetFATEntry
	cmp	ax,	0FFFh
	jz	Label_File_Loaded
	push	ax
	mov	dx,	RootDirSectors
	add	ax,	dx
	add	ax,	SectorBalance
;	add	bx,	[BPB_BytesPerSec]	

	jmp	Label_Go_On_Loading_File

Label_File_Loaded:
		
	mov	ax, 0B800h
	mov	gs, ax
	mov	ah, 0Fh				; 0000: 黑底    1111: 白字
	mov	al, 'G'
	mov	[gs:((80 * 0 + 39) * 2)], ax	; 屏幕第 0 行, 第 39 列。

%endmacro

%endif
