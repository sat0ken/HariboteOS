IPL_LINK_SCRIPT=ipl.lds
OS_LINK_SCRIPT=os.lds

IPL_SRC=ipl.s
OS_SRC=asmhead.s
BOOTPACK_SRC=bootpack.c
ASM_LIB_SRC=asmfunc.s

TARGET_DIR=bin
IPL_BIN=$(TARGET_DIR)/ipl.bin
OS_BIN=$(TARGET_DIR)/asmhead.bin
BOOTPACK_BIN=$(TARGET_DIR)/bootpack.bin
ASM_LIB_BIN=$(TARGET_DIR)/asmfunc.o

SYSTEM_IMG=$(TARGET_DIR)/haribote.sys
TARGET_IMG=$(TARGET_DIR)/haribote.img

LIST_IPL=$(TARGET_DIR)/ipl.lst
LIST_OS=$(TARGET_DIR)/os.lst
LIST_ASM_LIB=$(TARGET_DIR)/asmfunc.lst

QEMU=qemu-system-i386

all: $(TARGET_IMG)

$(OS_BIN): $(OS_SRC) $(OS_LINK_SCRIPT)
	mkdir -p $(TARGET_DIR)
	gcc -nostdlib -o $@ -T$(OS_LINK_SCRIPT) $(OS_SRC)
	gcc -T $(OS_LINK_SCRIPT) -c -g -Wa,-a,-ad $(OS_SRC) -o $(TARGET_DIR)/os.o > $(LIST_OS)

$(IPL_BIN): $(IPL_SRC) $(IPL_LINK_SCRIPT)
	mkdir -p $(TARGET_DIR)
	gcc -nostdlib -o $@ -T$(IPL_LINK_SCRIPT) $(IPL_SRC)
	gcc -T $(IPL_LINK_SCRIPT) -c -g -Wa,-a,-ad $(IPL_SRC) -o $(TARGET_DIR)/ipl.o > $(LIST_IPL)

$(BOOTPACK_BIN): $(BOOTPACK_SRC) $(ASM_LIB_BIN)
	mkdir -p $(TARGET_DIR)
	gcc -nostdlib -m32 -c -fno-pic -o $(TARGET_DIR)/bootpack.o $(BOOTPACK_SRC)
	ld -m elf_i386 -o $@ -T bootpack.lds -e HariMain --oformat=binary $(TARGET_DIR)/bootpack.o $(ASM_LIB_BIN)

$(ASM_LIB_BIN): $(ASM_LIB_SRC)
	mkdir -p $(TARGET_DIR)
	gcc -m32 -c -g -Wa,-a,-ad $(ASM_LIB_SRC) -o $(ASM_LIB_BIN) > $(LIST_ASM_LIB)

$(SYSTEM_IMG): $(OS_BIN) $(BOOTPACK_BIN)
	cat $(OS_BIN) $(BOOTPACK_BIN) > $@

$(TARGET_IMG): $(SYSTEM_IMG) $(IPL_BIN)
	mformat -f 1440 -B $(IPL_BIN) -C -i $(TARGET_IMG) ::
	mcopy $(SYSTEM_IMG) -i $(TARGET_IMG) ::

run: $(TARGET_IMG)
	NO_AT_BRIDGE=1 $(QEMU) -m 32 -drive format=raw,file=$(TARGET_IMG),if=floppy

debug:all
	NO_AT_BRIDGE=1  $(QEMU) -m 32 -drive format=raw,file=$(TARGET_IMG),if=floopy -gdb tcp:10000 -S

clean:
	rm -rf ./$(TARGET_DIR)