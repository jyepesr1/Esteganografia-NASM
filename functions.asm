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



strCmp:                                                           
   pop esi ; obtengo el primer String
   pop edi ; obtengo el segundo String
   pop ecx ; obtengo el tamaño del String
   cld ; Hace que la operación sea de izquierda a derecha                        
   repe cmpsb ; repite la operación mientras la flag ZF indique 0, o sea igual   
   jecxz equal                                                                   
   ret 1
                                                                                 
equal:                                                                           
   ret 0



errorParams:
   pop edx ; obtenemos el tamaño de lo que se imprimirá
   pop ecx ; obtenemos lo que se imprimirá
   mov eax,4 ; Servicio sys_write() Imprimimos el Mensaje de Error                                    
   mov ebx,1 ; STDOUT - consola                                                                    
   int 80h                                                                       
   jmp exit ; acabamos el programa


exit:                                                                            
   mov eax,1 ; Acabamos la Ejecución del programa                                
   mov ebx,1                                                                     
   int 80h                                                                       
              
