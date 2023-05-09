img :
	nasm ipl.nas -o ipl.img -l ipl.lst

run : ipl.img Makefile
	qemu-system-i386 -fda ipl.img

clean:
	rm ipl.img; rm ipl.lst