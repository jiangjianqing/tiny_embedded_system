                %include "boot_macros.inc"
                %include "bios_macros.inc"
                %include "fat12_macros.inc"

;----------以下为正式代码--------------


                macro_boot_begin

                jmp     short Label_Start
                nop
;这里开始加入文件系统描述（必须紧跟在nop之后）
                macro_fat12_defines

StartBootMessage:	
                db	"Start Boot"
StartBootMessageLen equ $-StartBootMessage

Label_Start:
                macro_boot_init_regs

;=======	clear screen
                macro_screen_clean

;=======	set cursor pos
                macro_screen_cursor_set_pos 2,10

;=======	display on screen : Start Booting......
                macro_screen_print   StartBootMessage , StartBootMessageLen 
                
                macro_screen_print   StartBootMessage , StartBootMessageLen ,8,20

;=======	reset floppy
                macro_floppy_reset

;代码停在此处
	            jmp     $


;-------填充剩余空间------
                macro_boot_end

