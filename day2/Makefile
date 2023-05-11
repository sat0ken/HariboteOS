img :
	nasm helloos3.asm -o ipl.img -l ipl.lst

run : ipl.img Makefile
	NO_AT_BRIDGE=1 qemu-system-i386 -drive file=ipl.img,format=raw,if=floppy

clean:
	rm ipl.img; rm ipl.lst