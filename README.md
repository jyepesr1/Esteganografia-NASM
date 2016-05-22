# Compilación:

* nasm -f elf hidemsg.asm 

# Enlazar las librerías:

* ld -m elf_i386 hidemsg.o -o hidemsg
