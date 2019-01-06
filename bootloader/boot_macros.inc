%ifndef BOOT_MACROS_INC
%define BOOT_MACROS_INC

%define         BIOS_START_ADDRESS      0x7c00
%xdefine        BASE_OF_STACK           BIOS_START_ADDRESS

%macro      macro_boot_begin 0
;注意：在这里不能写任何asm语句，包括数据声明。以fat12为例，boot所在的第一个扇区必须以3字节的跳转指令开头
;将程序的起始地址设置在0x7c00处，至于为什么是0x7c00，只有当年的bios工程师才会知道

;当bios跳转至引导程序时，CS寄存器和IP寄存器的值分别为0x0000和0x7c00,此时cpu处于实模式下，物理地址必须经过CS寄存器和IP寄存器转换才能得到，转换公式：
;物理地址 = CS << 4 + IP,见书 P32

                org                     BIOS_START_ADDRESS  ;如果没用org伪指令，那么编译器会把地址0x0000作为程序的起始地址。

BaseOfStack	    equ	                    BASE_OF_STACK

%endmacro

%macro      macro_boot_end 0
;=======	fill zero until whole sector

	            times	510 - ($ - $$)	db	0
	            dw	    0xaa55
%endmacro

;初始化段寄存器,bios并未要求sp必须为0x7c00,boot程序中极少设计stack操作  书P33
%macro      macro_boot_init_sregs 0
	            mov	    ax,	cs
	            mov	    ds,	ax
	            mov	    es,	ax
	            mov	    ss,	ax
	            mov	    sp,	BASE_OF_STACK
%endmacro


%endif  ;end of BOOT_MACROS_INC
