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
                macro_boot_init_sregs

;=======	clear screen
                macro_screen_clean

;=======	set cursor pos
                macro_screen_cursor_set_pos 2,10

;=======	display on screen : Start Booting......
                macro_screen_print   StartBootMessage , StartBootMessageLen ,0,0

;=======	reset floppy
                macro_disk_reset    0

;代码停在此处
	            ;jmp     $
                macro_search_loader

;-------填充剩余空间------
                macro_boot_end

