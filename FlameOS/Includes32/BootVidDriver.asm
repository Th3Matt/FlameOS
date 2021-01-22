
        
VIDMEM equ 0xB8000
White_on_Black equ 0x0F  

VDriver:
    .X: dd 0x00 ; Characters X
    .Y: dd 0x00 ; Characters Y
    .N: dd 0x00 ; Characters # (X + Y*80)
    
    .W: dd 0x50 ; Screen width
    .H: dd 0x18 ; Screen height
    .printChr:
        pusha
        mov ax, bx
        
        push edi
        
        mov edi, [.N]
        shl edi, 1
        add edi, VIDMEM
        
        mov [edi], ax
        
        mov edi, .N
        mov eax, 1
        add [edi], eax
        
        jmp .end
    
    .printStr:
        pusha
        
        .loop1:
            mov bl, [esi]
            
            cmp bl, 0
            je .end1
            
            mov bh, White_on_Black
            
            call .printChr
            
            inc esi
            
            jmp .loop1
        
    .end:
        pop edi
        popa
        ret
        
    .end1:
        popa
        ret
    
    .HEXTEMPLATE: db '0x0000'
    .HEXTable: dw '0123456789ABCDEF'
    
    .printHex:
        pusha
        
        mov bx, cx
        shr bx, 12
        mov bl, [.HEXTable + bx]
        mov [.HEXTEMPLATE+4], bl
        
        mov bx, cx
        shr bx, 8
        and bx, 0fh
        mov bl, [.HEXTable + bx]
        mov [.HEXTEMPLATE+5], bl
        
        mov bx, cx
        shr bx, 4
        and bx, 0fh
        mov bl, [.HEXTable + bx]
        mov [.HEXTEMPLATE+2], bl
        
        mov bx, cx
        and bx, 0fh
        mov bl, [.HEXTable + bx]
        mov [.HEXTEMPLATE+3], bl
        
        mov esi, .HEXTEMPLATE
        call .printStr
        
        popa
        ret
    

