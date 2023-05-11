ipl.bin :
	nasm ipl.asm -o ipl.bin -l ipl.lst

haribote.sys : haribote.asm
	nasm haribote.asm -o haribote.sys -l haribote.lst

haribote.img : ipl.bin haribote.sys
	mformat -f 1440 -C -B ipl.bin -i haribote.img ::
	mcopy haribote.sys -i haribote.img ::

run : haribote.img Makefile
	NO_AT_BRIDGE=1 qemu-system-i386 -drive file=haribote.img,format=raw,if=floppy

clean:
	rm *.img; rm *.lst; rm *.sys; rm *.bin;