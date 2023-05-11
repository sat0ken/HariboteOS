ipl.bin :
	nasm ipl.asm -o ipl.bin -l ipl.lst

asmhead.bin: asmhead.asm
	nasm asmhead.asm -o asmhead.bin -l asmhead.lst

nasmfunc.o: nasmfunc.asm			# nasmfunc.asmのバイナリファイル作成
	nasm -g -f elf nasmfunc.asm -o nasmfunc.o

bootpack.hrb: bootpack.c har.ld nasmfunc.o		# Cファイルをリンカスクリプトを用いてコンパイル, nasmfunc.oをリンクさせる
	gcc -march=i486 -m32 -nostdlib -T har.ld -g bootpack.c nasmfunc.o -fno-pic -o bootpack.hrb

haribote.sys : asmhead.bin bootpack.hrb
	cat asmhead.bin bootpack.hrb > haribote.sys

haribote.img : ipl.bin haribote.sys
	mformat -f 1440 -C -B ipl.bin -i haribote.img ::
	mcopy haribote.sys -i haribote.img ::

run : haribote.img Makefile
	NO_AT_BRIDGE=1 qemu-system-i386 -drive file=haribote.img,format=raw,if=floppy

debug : haribote.img Makefile
	NO_AT_BRIDGE=1 qemu-system-i386 -drive file=haribote.img,format=raw,if=floppy -gdb tcp:10000 -S

clean:
	rm *.img; rm *.lst; rm *.bin; rm *.sys; rm *.hrb; rm *.o;