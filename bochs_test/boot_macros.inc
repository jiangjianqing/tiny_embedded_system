
%define         BIOS_START_ADDRESS      0x7c00
%xdefine        BASE_OF_STACK           BIOS_START_ADDRESS

%macro      macro_boot_begin 0
;注意：在这里不能写任何asm语句，包括数据声明。以fat12为例，boot所在的第一个扇区必须以3字节的跳转指令开头
;将程序的起始地址设置在0x7c00处，至于为什么是0x7c00，只有当年的bios工程师才会知道
                org                     BIOS_START_ADDRESS

BaseOfStack	    equ	                    BASE_OF_STACK

%endmacro

%macro      macro_boot_end 0
;=======	fill zero until whole sector

	            times	510 - ($ - $$)	db	0
	            dw	    0xaa55
%endmacro

%macro      macro_boot_init_regs 0
	            mov	    ax,	cs
	            mov	    ds,	ax
	            mov	    es,	ax
	            mov	    ss,	ax
	            mov	    sp,	BASE_OF_STACK
%endmacro

