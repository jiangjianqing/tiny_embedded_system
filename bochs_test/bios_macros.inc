;=======	clear screen
%macro      macro_screen_clean 0
	            mov	ax,	0600h
	            mov	bx,	0700h
	            mov	cx,	0
	            mov	dx,	0184fh
	            int	10h
%endmacro

%macro      macro_screen_display 2
;=======	display on screen 

	            mov	ax,	1301h
	            mov	bx,	000fh
	            mov	dx,	0000h
	            mov	cx,	%2
	            push	ax
	            mov	ax,	ds
	            mov	es,	ax
	            pop	ax
	            mov	bp,	%1
	            int	10h
%endmacro

%macro      macro_screen_cursor_pos 2
	            mov	ax,	0200h
	            mov	bx,	0000h
	            mov     dl,%2   ;列
                mov     dh,%1   ;行
                ;mov	dx,	0000h
	            int	10h
%endmacro

%macro      macro_floppy_reset 0
;=======	reset floppy

	            xor	ah,	ah
	            xor	dl,	dl
	            int	13h
%endmacro
