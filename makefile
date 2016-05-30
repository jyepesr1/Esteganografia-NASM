hidemsg: hidemsg.o
	ld -m elf_i386 hidemsg.o -o hidemsg

hidemsg.o: hidemsg.asm
	nasm -f elf hidemsg.asm

clean:
	rm -f *.o hidemsg second.ppm
