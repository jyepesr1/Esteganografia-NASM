%include    'functions.asm'

section .data

numArgs           equ    6
MSGError1         db   "Error el modo de uso es hidemsg 'mensaje' –f ARCHIVO.in –o \
ARCHIVO.out",0xa ; 0xa es salto de línea, 10 en ASCII decimal
MSGError1Len      equ   $ - MSGError1  ; tamaño del mensaje
flag1             db   "-f"
flag1Len          equ   $ - flag1

section .bss

image             resb  1024
imageLen          resb  1024
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

   pop eax ; Obtengo el primer parametro útil "mensaje"

mensaje:
   mov [message],eax ; Guardo el mensaje en message
   call strLen ; obtengo el tamaño del mensaje
   mov [messageLen],eax

parameter1:
   pop eax ; Obtengo la primer flag -f

   push flag1Len
   push flag1
   push eax
   call strCmp
   cmp eax,0
   je parameter2 ; Si es cero, fueron iguales por tanto seguimos con el otro parámetro
   push MSGError1  ; fueron diferentes así que enviamos el mensaje a imprimir y acabamos el programa
   push MSGError1Len
   call errorParams
   
parameter2:
   pop ebx ; Obtengo el nombre de la imagen

   mov eax,[messageLen]
   mov edx,3
   mul edx  ; Obtengo el tamaño del mensaje y lo multiplico por 3, para saber cuantos pixeles necesito cambiar
   mov [imageLen],eax

   mov eax,5 ; sys_open()
   mov ecx,0 ; solo para acceso de lectura
   mov edx,0777 ; Permisos de lectura, escritura y ejecución para todos rwx
   int 80h

   mov [fd_in],eax ; Guardo el Descriptor de Archivos para leer de él

   mov eax,3 ; sys_read()
   mov ebx,[fd_in] ; el descriptor del archivo que abrimos
   mov ecx,image ; el apuntador donde guardaremos el contenido de la imagen
   mov edx,[imageLen] ; la cantidad de pixeles que necesitamos
   int 80h








   


