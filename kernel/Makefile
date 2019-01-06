CROSS =   
CC = $(CROSS)gcc  
CXX = $(CROSS)g++  
DEBUG =   
CFLAGS = $(DEBUG) -Wall -c  
MV = mv -f  
RM = rm -rf  
LN = ln -sf  

TOP_PATH = $(shell pwd)
SRC_PATH = $(TOP_PATH)/src/
#BIN_PATH = $(TOP_PATH)/bin/
BIN_PATH = $(TOP_PATH)/../bin/
LIB_PATH = $(TOP_PATH)/lib/
INC_PATH = $(TOP_PATH)/include/

MOUNT_PATH = /media/

SRCS = $(wildcard $(SRC_PATH)*.cpp)
OBJS = $(patsubst %.cpp, %.o, $(SRCS))
#LIBS += $(LIB_PATH)libconfig.a
LIBS += -lconfig

VERSION = 1.0.0.0
TARGET = adx$(VERSION)

build: system
	objcopy -I elf64-x86-64 -S -R ".eh_frame" -R ".comment" -O binary $(BIN_PATH)system $(BIN_PATH)kernel.bin

system:	head.o main.o 
	ld -b elf64-x86-64 -o $(BIN_PATH)system $(BIN_PATH)head.o $(BIN_PATH)main.o -T Kernel.lds 

main.o:	main.c
	gcc  -mcmodel=large -fno-builtin -m64 -c main.c -o $(BIN_PATH)main.o

head.o:	head.S
	gcc -E  head.S > $(BIN_PATH)head.s
	as --64 -o $(BIN_PATH)head.o $(BIN_PATH)head.s

mount_and_copy: build
	sudo mount $(BIN_PATH)boot.img $(MOUNT_PATH) -t vfat -o loop
	sudo cp $(BIN_PATH)kernel.bin $(MOUNT_PATH)
	sudo umount $(MOUNT_PATH)

start:build
	bochs -f ../bootloader/bochsrc

clean:
	rm -rf *.o *.s~ *.s *.S~ *.c~ *.h~ system  Makefile~ Kernel.lds~ kernel.bin 
	sudo mount $(BIN_PATH)boot.img $(MOUNT_PATH) -t vfat -o loop
	sudo rm -rf $(MOUNT_PATH)kernel.bin
	sudo umount $(MOUNT_PATH)

