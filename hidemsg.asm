%include    'functions.asm'

%define sizeof(x) x %+ _size

struc STAT
    .st_dev:        resd 1
    .st_ino:        resd 1
    .st_mode:       resw 1
    .st_nlink:      resw 1
    .st_uid:        resw 1
    .st_gid:        resw 1
    .st_rdev:       resd 1
    .st_size:       resd 1
    .st_blksize:    resd 1
    .st_blocks:     resd 1
    .st_atime:      resd 1
    .st_atime_nsec: resd 1
    .st_mtime:      resd 1
    .st_mtime_nsec: resd 1
    .st_ctime:      resd 1
    .st_ctime_nsec: resd 1
    .unused4:       resd 1
    .unused5:       resd 1
endstruc

section .data

numArgs           equ   6
MSGError1         db    "Error el modo de uso es hidemsg 'mensaje' –f ARCHIVO.in –o \
ARCHIVO.out",0xa ; 0xa es salto de línea, 10 en ASCII decimal
MSGError1Len      equ   $ - MSGError1  ; tamaño del mensaje
flag1             db    "-f"
flag1Len          equ   $ - flag1

section .bss

stat              resb  sizeof(STAT)
image             resb  5242880 ; 5MB
imageName         resb  1024
imageLen          resb  1024 ; 5MB
outFileName       resb  1024
message           resb  1024
messageLen        resb  1024
fd_in             resb  1
fd_out            resb  1


section .text
   global _start

_start:
   pop eax ; Obtiene el número de parametros

  ; cmp eax, [numArgs] ; Compara la cantidad de parametros, deber ser igual a 6
   ;jne errorParams

   pop eax ; Obtengo el nombre del programa


mensaje:
   pop eax ; Obtengo el primer parametro útil "mensaje"

   mov [message],eax ; Guardo el mensaje en message
   call strLen ; obtengo el tamaño del mensaje
   mov [messageLen],eax


parameter1:
   pop ecx ; Obtengo la primer flag -f

   mov eax,ecx
   call strLen
   cmp eax,2
   jne errorParams

   cmp byte[ecx],'-'
   jne errorParams
   cmp byte[ecx+1],'f'
   jne errorParams


parameter2:
   pop ebx ; Obtengo el nombre de la imagen

   mov [imageName],ebx

   mov eax,106 ; sys_newstat
   mov ebx,[imageName]
   mov ecx,stat
   int 80h

   mov eax,[stat + STAT.st_size] ; El tamaño del archivo lo podemos hallar accediendo al star mas un offset de 20, pero por legibilidad lo hacemos así
   mov [imageLen],eax


parameter3:
   pop ecx

   mov eax,ecx
   call strLen
   cmp eax,2
   jne errorParams

   cmp byte[ecx],'-'
   jne errorParams
   cmp byte[ecx+1],'o'
   jne errorParams


parameter4:
   pop eax
   mov [outFileName],eax

   mov eax,5 ; sys_open()
   mov ebx,[imageName]
   mov ecx,0 ; solo para acceso de lectura
   mov edx,0777 ; Permisos de lectura, escritura y ejecución para todos rwx
   int 80h

   mov [fd_in],eax ; Guardo el Descriptor de Archivos para leer de él

   mov eax,3 ; sys_read()
   mov ebx,[fd_in] ; el descriptor del archivo que abrimos
   mov ecx,image ; el apuntador donde guardaremos el contenido de la imagen
   mov edx,[imageLen] ; la cantidad de bytes que necesitamos
   int 80h

   mov eax,6 ; sys_close()
   mov ebx,[fd_in]
   int 80h

   mov eax,8  ; sys_create()
   mov ebx,[outFileName]
   mov ecx,0420 ; 644 octal -rw-r--r--
   int 80h

   mov [fd_out],eax

   mov eax,4  ; sys_write()
   mov ebx,[fd_out]
   mov ecx,image
   mov edx,[imageLen]
   int 80h

   mov eax,6 ; sys_close()
   mov ebx,[fd_out]
   int 80h


   jmp exit












