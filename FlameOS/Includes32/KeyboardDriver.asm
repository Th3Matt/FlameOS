
KDriver:
    
    .init:
        call .WaitW
        mov al, 0xAD
        out 0x64, al
        
        call .WaitW
        mov al, 0xA7
        out 0x64, al
        
        in al, 0x60
        
        call .WaitW
        mov al, 0x20
        out 0x64, al
        
        call .WaitR
        in bl, 0x60
        and bl, 10111100b
        
        call .WaitW
        mov al, 0x60
        out 0x64, al
        
        call .WaitW
        out 0x64, bl
        
        call .WaitW
        mov al, 0xAA
        out 0x64, al
        
        call .WaitR
        in bl, 0x60
        cmp bl, 0x55
        jne .err
        
        call .WaitW
        mov al, 0xAB
        out 0x64, al
        
        call .WaitR
        in bl, 0x60
        cmp bl, 0
        jne .err2
        
        call .WaitW
        mov al, 0xAE
        out 0x64, al
        
        .Write1:
            call .WaitW
            mov al, 0xFF
            out 0x60, al
            
            call .WaitR
            in bl, 0x60
            cmp bl, 0xFE
            je .Write1
            cmp bl, 0xAA
            jne .err3
            
        .Write2:
            call .WaitW
            mov al, 0xF2
            out 0x60, al
            
            call .WaitR
            in bl, 0x60
            cmp bl, 0xFE
            je .Write2
        
        call .WaitR
        in bl, 0x60
        mov bh, 0
        mov [.A], bx
        
        mov esi, .A
        call VDriver.printHex
        
        ret
        
        call .WaitR
        
    .A: dw 0x00
    
    .WaitW:
        in al, 0x64
        
        test al, 1
        jnz .WaitW
        ret
    
    .WaitR:
        in al, 0x64
        
        test al, 0
        jz .WaitR
        ret
    
    .errMsg1: db 'Failed to test PS/2 controller.', 0
    .errMsg2: db 'No working PS/2 ports.', 0
    .errMsg3: db 'Unable to reset PS/2 device', 0
    
    .err:
        mov esi, .errMsg1
        call VDriver.printStr
        
        hlt
    
    .err2:
        mov esi, .errMsg2
        call VDriver.printStr
        
        hlt
    
    .err3:
        mov esi, .errMsg3
        call VDriver.printStr
        
        hlt
    
