
RSDPStr: dw 'RSD PTR '
RSDPerr1: dw 'Failed to find RSDP.'

findRSDP:
    mov esi, RSPDStr
    mov edi, 0x80000
    mov ebx, 0x80400
    mov edx, 0x16
    call PMT.findStr
    
    cmp edi, 0
    jne .found
    
    mov edi, 0xE0000
    mov ebx, 0xFFFFF
    call PMT.findStr
    
    cmp edi, 0
    jne .found
    
    mov esi, RSDPerr1
    call VideoDriver
    
    hlt
    
    .found:
        
