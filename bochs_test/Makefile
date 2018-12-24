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

SRCS = $(wildcard $(SRC_PATH)*.cpp)
OBJS = $(patsubst %.cpp, %.o, $(SRCS))
#LIBS += $(LIB_PATH)libconfig.a
LIBS += -lconfig

VERSION = 1.0.0.0
TARGET = adx$(VERSION)

build:boot.img boot.bin
	ls -al

boot.bin:boot.asm bios_macros.inc boot_macros.inc
	nasm boot.asm -i $(TOP_PATH)/  -o boot.bin

boot.img:boot.bin
	dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc	

start:build
	bochs -f bochsrc
