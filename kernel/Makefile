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
BIN_PATH = $(TOP_PATH)/bin/
LIB_PATH = $(TOP_PATH)/lib/
INC_PATH = $(TOP_PATH)/include/

MOUNT_PATH = /media/

SRCS = $(wildcard $(SRC_PATH)*.cpp)
OBJS = $(patsubst %.cpp, %.o, $(SRCS))
#LIBS += $(LIB_PATH)libconfig.a
LIBS += -lconfig

VERSION = 1.0.0.0
TARGET = adx$(VERSION)

all: system
	objcopy -I elf64-x86-64 -S -R ".eh_frame" -R ".comment" -O binary $(BIN_PATH)system $(BIN_PATH)kernel.bin

system:	head.o main.o 
	ld -b elf64-x86-64 -o $(BIN_PATH)system $(BIN_PATH)head.o $(BIN_PATH)main.o -T Kernel.lds 

main.o:	main.c
	gcc  -mcmodel=large -fno-builtin -m64 -c main.c -o $(BIN_PATH)main.o

head.o:	head.S
	gcc -E  head.S > $(BIN_PATH)head.s
	as --64 -o $(BIN_PATH)head.o $(BIN_PATH)head.s

clean:
	rm -rf *.o *.s~ *.s *.S~ *.c~ *.h~ system  Makefile~ Kernel.lds~ kernel.bin 

