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

build:boot.img loader.bin
	ls -al $(BIN_PATH)

boot.bin:boot.asm bios_macros.inc boot_macros.inc fat12_macros.inc
	nasm boot.asm -i $(TOP_PATH)/  -o $(BIN_PATH)boot.bin

boot.img:boot.bin
	dd if=$(BIN_PATH)boot.bin of=$(BIN_PATH)boot.img bs=512 count=1 conv=notrunc	

loader.bin:loader.asm bios_macros.inc boot_macros.inc fat12_macros.inc
	nasm loader.asm -i $(TOP_PATH)/  -o $(BIN_PATH)loader.bin

start:build
	bochs -f bochsrc

#all:$(TARGET)
#       	$(MV) $(TARGET) $(BIN_PATH)
#	$(LN) $(BIN_PATH)/$(TARGET) $(BIN_PATH)/adx

#$(TARGET) : $(OBJS)
#    	$(CXX) $^ -o $@ -L$(LIB_PATH) $(LIBS)

#$(OBJS):%.o : %.cpp
#    	$(CXX) $(CFLAGS) $< -o $@ -I$(INC_PATH)

.PHONY : clean
clean:
	$(RM) ${BIN_PATH}*.bin
    #$(RM) $(TARGET) $(OBJS)

