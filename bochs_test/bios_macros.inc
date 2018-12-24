;/***************************************************
;	功能：
;        清空当前屏幕内容
;
;   参数描述：无
;
;***************************************************/
%macro      macro_screen_clean 0
	            mov	    ax,	0600h
	            mov	    bx,	0700h
	            mov	    cx,	0
	            mov	    dx,	0184fh
	            int	    10h
%endmacro

;/***************************************************
;	功能：
;        设定游标的行数和列数
;
;   参数描述：
;       %1 : 游标行数
;       %2 : 游标列数	
;
;***************************************************/
%macro      macro_screen_cursor_set_pos 2
	            mov	    ax,	0200h
	            mov	    bx,	0000h
                mov     dh,%1   ;行
	            mov     dl,%2   ;列
                ;mov	dx,	0000h
	            int	    10h
%endmacro


;/***************************************************
;	功能：
;        将游标的行数和列数读取到dh,dl中
;
;   参数描述：无
;   返回值:
;       dh=行号，dl=列号   CH＝光标的起始行 CL＝光标的终止行     
;
;***************************************************/
%macro      macro_screen_cursor_get_pos 0
                push    ax
                push    bx

                mov     ah, 3
                mov     bh, 0
                int     10h ;读取目前的光标信息。dh=行号，dl=列号

                pop     bx
                pop     ax
%endmacro

;/***************************************************
;	功能：
;        在屏幕上指定位置显示字符串
;
;   参数描述：
;       %1 : 字符串地址
;       %2 : 字符串长度
;       %3 : 游标行数
;       %4 : 游标列数	
;
;***************************************************/
%macro      macro_screen_print 2-5 -1,0,000fh
	            mov	    ax,	1301h
	            mov	    bx,	%5
%if %0=2
                macro_screen_cursor_get_pos          
%else      
    %if %2>0
                mov     dh, %3  ;行
                mov     dl, %4  ;列
	            ;mov	    dx,	0000h
    %endif
%endif
	            mov	    cx,	%2
	            push	ax
	            mov	    ax,	ds
	            mov	    es,	ax
	            pop	    ax
	            mov	    bp,	%1
	            int	    10h
%endmacro

;/***************************************************
;	功能：
;        设定游标的行数和列书
;
;   参数描述：
;       %1 : 游标行数
;       %2 : 游标列数	
;
;***************************************************/
%macro      macro_floppy_reset 0-1 0
	            xor	    ah,	ah
                mov     dl, %1
	            ;xor	dl,	dl
	            int	    13h
%endmacro
