                %include "boot_macros.inc"
                %include "bios_macros.inc"

;----------以下为正式代码--------------


                macro_begin_bios

                jmp     short Label_Start
                nop

StartBootMessage:	
                db	"Start Boot"
StartBootMessageLen equ $-StartBootMessage

Label_Start:
                macro_boot_init_regs

;=======	clear screen
                macro_screen_clean

;=======	set focus
                macro_screen_cursor_pos 2,10

;=======	display on screen : Start Booting......
                ;macro_screen_display   StartBootMessage , StartBootMessageLen

;=======	reset floppy
                macro_floppy_reset

;代码停在此处
	jmp	$


;-------填充剩余空间------
                macro_end_bios

