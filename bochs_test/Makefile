build:boot.img boot.bin
	ls -al

boot.bin:boot.asm
	nasm boot.asm -o boot.bin

boot.img:boot.bin
	dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc	

start:boot.img
	bochs -f bochsrc
