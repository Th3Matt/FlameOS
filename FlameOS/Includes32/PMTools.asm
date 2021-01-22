
; Input: esi - string start address, edi - search start address, ebx - search end address, edx - search every #,

; Output: edi - address of found string

PMT.findStr:
    pusha
    xor ecx, ecx
    
    .loop:
        mov al, [esi]
        mov ah, [edi]
        
        cmp al, ah
        je .foundChr
        jmp .notChr
    
    .foundChr:
        inc ecx
        inc esi
        mov al, [esi]
        
        cmp al, 0
        je .end
        
        inc edi
        jmp .loop
    
    .notChr:
        sub esi, ecx
        sub edi, ecx
        xor ecx, ecx
        
        cmp edi, ebx
        je .fail
        
        add edi, edx
        
        jmp .loop
    
    .fail:
        xor edi, edi
        
        popa
        ret
    
    .end:
        sub edi, ecx
        
        popa
        ret
