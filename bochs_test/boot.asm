                %include "boot_macros.inc"
                %include "bios_macros.inc"

;----------以下为正式代码--------------


                macro_begin_bios

                jmp     Label_Start

StartBootMessage:	
                db	"Start Boot..."
StartBootMessageLen equ $-StartBootMessage

Label_Start:

	            mov	    ax,	cs
	            mov	    ds,	ax
	            mov	    es,	ax
	            mov	    ss,	ax
	            mov	    sp,	BASE_OF_STACK

;=======	clear screen
                macro_screen_clean

;=======	set focus

	mov	ax,	0200h
	mov	bx,	0000h
	mov	dx,	0000h
	int	10h

;=======	display on screen : Start Booting......
    macro_display   StartBootMessage , StartBootMessageLen

;=======	reset floppy

	xor	ah,	ah
	xor	dl,	dl
	int	13h


;代码停在此处
	jmp	$


;-------填充剩余空间------
                macro_end_bios

