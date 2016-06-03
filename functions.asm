strLen:
   mov ebx,eax   ; EAX y EBX apuntan a la misma posición del String

   .loop:
      cmp byte [eax], 0 ; el String antes de llamar al procedimiento debe estar en EBX
      jz .finished
      inc eax
      jmp .loop

   .finished:
      sub eax,ebx ; compara la diferencia de donde empezó el String hasta donde acabó, para hallar el tamaño
   ret



;strCmp:
;   cld ; Hace que la operación sea de izquierda a derecha
;   repe cmpsb ; repite la operación mientras la flag ZF indique 0, o sea igual
;   jecxz exit
;   jmp errorParams


char2Bin:
   mov ecx,7
   mov edx,edi ; Guardo la posición inicial del buffer

   .nextBit:
      shl bl,1
      setc byte[edi]
     ;add byte[edi],'0'
      inc edi
      dec ecx
      jns .nextBit
   ret



errorParams:
   mov eax,4 ; Servicio sys_write() Imprimimos el Mensaje de Error
   mov ebx,1 ; STDOUT - consola
   mov ecx,MSGError1
   mov edx,MSGError1Len
   int 80h
   jmp exit ; acabamos el programa


errorOpeningFile:
   mov eax,4 ; Servicio sys_write() Imprimimos el Mensaje de Error
   mov ebx,1 ; STDOUT - consola
   mov ecx,MSGError2
   mov edx,MSGError2Len
   int 80h
   jmp exit ; acabamos el programa


errorReadingFile:
   mov eax,4 ; Servicio sys_write() Imprimimos el Mensaje de Error
   mov ebx,1 ; STDOUT - consola
   mov ecx,MSGError3
   mov edx,MSGError3Len
   int 80h
   jmp exit ; acabamos el programa


exit:
   mov eax,1 ; Acabamos la Ejecución del programa
   mov ebx,0
   int 80h
