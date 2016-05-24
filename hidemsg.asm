%include    'functions.asm'

section .data

numArgs           equ   6
MSGError1         db    "Error el modo de uso es hidemsg 'mensaje' –f ARCHIVO.in –o \
ARCHIVO.out",0xa ; 0xa es salto de línea, 10 en ASCII decimal
MSGError1Len      equ   $ - MSGError1  ; tamaño del mensaje
flag1             db    "-f"
flag1Len          equ   $ - flag1
imageLen          equ   5242880 ; 5MB

section .bss

image             resb  5242880 ; 5MB
imageName         resb  1024
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

  ; mov eax,4
  ;mov ebx,1
  ; mov ecx,[message]
  ; mov edx,[messageLen]
  ; int 80h
  ; call exit

parameter1:
   pop ecx ; Obtengo la primer flag -f

   mov eax,ecx
   call strLen
   cmp eax,2
   jg errorParams

   cmp byte[ecx],'-'
   jne errorParams
   cmp byte[ecx+1],'f'
   jne errorParams


parameter2:
   pop ebx ; Obtengo el nombre de la imagen

;   mov [imageName],ebx

   mov eax,5 ; sys_open()
   mov ecx,0 ; solo para acceso de lectura
   mov edx,0777 ; Permisos de lectura, escritura y ejecución para todos rwx
   int 80h

   mov [fd_in],eax ; Guardo el Descriptor de Archivos para leer de él

   mov eax,3 ; sys_read()
   mov ebx,[fd_in] ; el descriptor del archivo que abrimos
   mov ecx,image ; el apuntador donde guardaremos el contenido de la imagen
   mov edx,imageLen ; la cantidad de pixeles que necesitamos
   int 80h

   mov eax,6 ; sys_close()
   mov ebx,[fd_in]
   int 80h

parameter3:
   pop ecx

   mov eax,ecx
   call strLen
   cmp eax,2
   jg errorParams

   cmp byte[ecx],'-'
   jne errorParams
   cmp byte[ecx+1],'o'
   jne errorParams


parameter4:
   pop ebx

   mov eax,8  ; sys_create()
   mov ecx,0777
   int 80h

   mov [fd_out],eax

   mov eax,4  ; sys_write()
   mov ebx,[fd_out]
   mov ecx,image
   mov edx,imageLen
   int 80h

   mov eax,6 ; sys_close()
   mov ebx,[fd_out]
   int 80h

   jmp exit












