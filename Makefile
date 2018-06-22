CC      = arm-linux-gcc
LD      = arm-linux-ld
AR      = arm-linux-ar
OBJCOPY = arm-linux-objcopy
OBJDUMP = arm-linux-objdump	
	
DIR_INC = ./include
DIR_SRC = ./src
DIR_OBJ = ./objs
DIR_BIN = ./bin

SRC_C = $(wildcard ${DIR_SRC}/*.c)  
SRC_S = $(wildcard ${DIR_SRC}/*.S) 
OBJ = $(patsubst %.S,${DIR_OBJ}/%.o,$(notdir ${SRC_S})) $(patsubst %.c,${DIR_OBJ}/%.o,$(notdir ${SRC_C})) lib/libc.a

TARGET = lcd.bin

BIN_TARGET = ${DIR_BIN}/${TARGET}

CFLAGS 		:= -Wall -O2
CPPFLAGS   	:= -nostdinc -I${DIR_INC}

export 	CC LD AR OBJCOPY OBJDUMP DIR_INC CFLAGS CPPFLAGS

${BIN_TARGET}:${OBJ}
	${LD} -Tlcd.lds -o lcd_elf objs/interrupt.o objs/serial.o objs/lcddrv.o objs/framebuffer.o objs/lcdlib.o objs/main.o lib/libc.a
	${OBJCOPY} -O binary -S lcd_elf $@
	${OBJDUMP} -D -m arm lcd_elf > lcd.dis

.PHONY : lib/libc.a
lib/libc.a:
	cd lib; make; cd ..		
	
${DIR_OBJ}/%.o:${DIR_SRC}/%.c
	${CC} $(CPPFLAGS) $(CFLAGS) -c -o $@ $<
	
${DIR_OBJ}/%.o:${DIR_SRC}/%.S
	${CC} $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

clean:
	make  clean -C lib
	rm -f ./bin/* ./objs/*.o
