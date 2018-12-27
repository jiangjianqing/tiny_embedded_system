                %include "loader.inc"
                %include "bios_macros.inc"
org	LoaderOrg
                jmp     Label_Start

Label_Start:
	            mov	ax,	cs
	            mov	ds,	ax
	            mov	es,	ax
	            mov	ax,	0x00
	            mov	ss,	ax
	            mov	sp,	0x7c00

;=======	display on screen : Start Loader......
                macro_screen_cursor_set_pos 2,0
                macro_screen_print   StartLoaderMessage , StartLoaderMessageLen

	            jmp	$

;=======	display messages

StartLoaderMessage:	db	"Start Loader11111 my test"
StartLoaderMessageLen   equ $-StartLoaderMessage





