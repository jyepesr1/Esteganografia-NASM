section .data

numArgs equ 6
MSGError1 db "Error el modo de uso es hidemsg 'mensaje' –f ARCHIVO.in –o \
ARCHIVO.out",0xa ; 0xa es salto de línea, 10 en ASCII decimal
MSGError1Len equ $ - MSGError1  ; tamaño del mensaje
param1 db "-f"
param1Len equ $ - param1



section .bss

imageName resb 1024
mesage resb 1024
mesageLen resb 1024


section .text
   global main

main:
   pop eax ; Obtiene el número de parametros

   cmp eax, [numArgs] ; Compara la cantidad de parametros, deber ser igual a 6
   jne errorParams

   pop ebx ; Obtengo el nombre del programa

   pop ebx ; Obtengo el primer parametro útil "mensaje"

mensaje:
   mov mesage,ebx
   call obtener_tamanoString
   mov [mesageLen],eax



   
comparar_Strings:
   mov esi,eax ; Primer String se almacena en EAX
   mov edi,ebx ; Segundo String se almacena en EBX
   mov ecx,edx ; El tamaño de los Strings se guarda en EDX
   cld ; Hace que la operación sea de izquierda a derecha
   repe cmpsb ; repite la operación mientras la flag ZF indique 0, o sea igual
   jecxz equal
   jmp errorParams
   
equal:
   ret



obtener_tamanoString:
   mov eax,mesage
   mov ecx,0

   .loop:
      cmp byte [eax + ecx], 0
      inc ecx
      jne .loop      
   ret



errorParams:
   mov eax,4 ; Imprimimos el Mensaje de Error
   mov ebx,1
   mov ecx,MSGError1
   mov edx,MSGError1Len
   int 80h
   jmp exit


exit:
   mov eax,1 ; Acabamos la Ejecución del programa
   mov ebx,1
   int 80h



