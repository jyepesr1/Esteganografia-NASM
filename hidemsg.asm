%include    'functions.asm'

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
MSGError1         db    "Error, el modo de uso es hidemsg 'mensaje' –f ARCHIVO.in –o \
ARCHIVO.out",0xa ; 0xa es salto de línea, 10 en ASCII decimal
MSGError1Len      equ   $ - MSGError1  ; tamaño del mensaje
MSGError2         db    "Error, abriendo el archivo de entrada, por favor revise la \
ruta y nombre de este.",0xa
MSGError2Len      equ   $ - MSGError2  ; tamaño del mensaje
MSGError3         db    "Error, leyendo el archivo de entrada, por revise si dicho archivo.",0xa
MSGError3Len      equ   $ - MSGError3  ; tamaño del mensaje
MSGError4         db    "Error, el formato de la imagen de entrada no es P6",0xa
MSGError4Len      equ   $ - MSGError4
one               times 8 db 1

section .bss

stat              resb  64
image             resb  5242880 ; 5MB
imageWithoutHeader resb 5242880 ; 5MB
imageName         resb  1024
imageLen          resb  1024
outFileName       resb  1024
message           resb  1024
fd_in             resb  1
fd_out            resb  1
binary            resb  1024 ; Buffer para almacenar el char en binario
binaryLen         resb  2    ; tamaño del buffer del binario
header            resb  512   ; buffer para almacenar el header de la img
headerLen         resb  2    ; tamaño del buffer del header
bodyLen           resb  2    ; tamaño de la img sin el header
messageLen        resb  2

section .text
   global _start

_start:
   pop eax ; Obtiene el número de parametros

   cmp eax, numArgs ; Compara la cantidad de parametros, deber ser igual a 6
   jne errorParams

   pop eax ; Obtengo el nombre del programa


mensaje:
   pop eax ; Obtengo el primer parametro útil "mensaje"

   mov [message],eax ; Guardo el mensaje en message
   call strLen ; obtengo el tamaño del mensaje
   mov [messageLen],eax

   cmp byte[messageLen],0
   je errorParams


parameter1:
   pop ecx ; Obtengo la primer bandera -f

   mov eax,ecx
   call strLen ; calculo su longitud para hacer la comprobación de que este correcta dicha bandera
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


   mov eax,[stat + STAT.st_size] ; El tamaño del archivo lo podemos hallar
                                 ;accediendo al stat mas un offset de 20,
                                 ;pero por legibilidad lo hacemos así
   mov [imageLen],eax


parameter3:
   pop ecx ; Obtengo la segunda bandera -o

   mov eax,ecx
   call strLen ; calculo su longitud para hacer la comprobación de que este correcta dicha bandera
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

   test eax,eax
   js errorOpeningFile


   mov [fd_in],eax ; Guardo el Descriptor de Archivos para leer de él

   mov eax,3 ; sys_read()
   mov ebx,[fd_in] ; el descriptor del archivo que abrimos
   mov ecx,image ; el apuntador donde guardaremos el contenido de la imagen
   mov edx,[imageLen] ; la cantidad de bytes que necesitamos
   int 80h

   test eax,eax
   js errorReadingFile


   mov eax,6 ; sys_close()
   mov ebx,[fd_in]
   int 80h


   cmp byte[image],'P'
   jne errorFormat
   cmp byte[image+1],'6'
   jne errorFormat


mov esi,[message]
mov edi,binary
mov eax,edi
convert2Bits:
   cmp byte[esi],0 ; Comparo con 0 para saber si llegue al final del mensaje
   je .convertFinished

   mov bl,byte[esi] ; mueve un byte a bl para operar sobre este con shl
   call char2Bin

   inc esi ; obtengo el siguiente caracter del mensaje
   jmp convert2Bits

   .convertFinished:
      sub edi,eax ; Realizo una resta para conocer el tamaño final de la cadena de bits
      mov [binaryLen],edi


getHeader:

   mov ecx,image
   mov esi,0  ; ESI es usado para llevar la cantidad de "Fin de líneas" encontrados
   mov edx,0  ; EDX es usado para al final saber el tamaño del Header
   .loop:
      cmp byte[ecx],10 ; Comparo con 10 para saber si he encontrado un "Fin de Línea"
      je .finDeLinea

      inc ecx   ; Obtengo el siguiente caracter
      inc edx   ; Incremento el tamaño
      jmp .loop

   .finDeLinea:
      inc esi   ; Incremento la cantidad de "Fin de Líneas" encontrados
      inc edx   ; Incremento el tamaño
      cmp esi,3 ; Comparo para saber si he encontrado 3 "Fin de Línea" y así sé que el Header acaba
      je .finished
      inc ecx
      jmp .loop

   .finished:
      mov [headerLen],edx ; Muevo el tamaño final del Header a la variable


changeImage:

   mov esi,image  ; Muevo la imagen a ESI para manipularla
   add esi,[headerLen]

   mov ecx,[messageLen]
   mov edx,binary  ; Muevo la cadena binaria del mensaje a EDX

   movq mm2,[one]

   .imageLoop:

      movq mm0,[esi]
      movq mm1,[edx]

      psubusb mm0,mm2
      por mm0,mm1

      movq [esi],mm0

      add esi,8
      add edx,8

      dec ecx
      jnz .imageLoop
      jmp createFile




createFile:

   mov eax,8  ; sys_creat()
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












