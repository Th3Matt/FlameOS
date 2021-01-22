 
PS_2:
    .init:
        pusha
        
        mov bl, 2
        call IOPrint.SetXY
        
        mov edx, 1
        mov bh, 0
        mov esi, Prefixes.KernelINFO
        call IOPrint.Str
        
        mov esi, .progress1
        call IOPrint.Str
        
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
        in al, 0x60
        and al, 10111100b
        push ax
        
        call .WaitW
        mov al, 0x60
        out 0x64, al
        
        call .WaitW
        pop ax
        out 0x64, al
        
        call .WaitW
        mov al, 0xAA
        out 0x64, al
        
        call .WaitR
        in al, 0x60
        cmp al, 0x55
        jne .err
        
        call .WaitW
        mov al, 0xAB
        out 0x64, al
        
        call .WaitR
        in al, 0x60
        cmp al, 0
        jne .err2
        
        call .WaitW
        mov al, 0xAE
        out 0x64, al
        
        mov bl, 2
        call IOPrint.SetXY
        
        mov bh, 0
        mov esi, Prefixes.KernelINFO
        call IOPrint.Str
        
        mov esi, .progress2
        call IOPrint.Str
        
        .Write1:
            call .WaitW
            mov al, 0xFF
            out 0x60, al
            
            .Write1.ACK:
            
            call .WaitR
            in al, 0x60
            
            cmp al, 0xFA
            je .Write1.ACK
            
            cmp al, 0xFE
            je .Write1
            cmp al, 0xAA
            jne .err3
            
        .Write2:
            call .WaitW
            mov al, 0xF2
            out 0x60, al
            
            .Write2.ACK:
            
            call .WaitR
            in al, 0x60
            
            cmp al, 0xFA
            je .Write2.ACK
            
            cmp al, 0xFE
            je .Write2
        
        call .WaitR
        in al, 0x60
        in al, 0x60
        
        mov bl, 2
        call IOPrint.SetXY
        
        mov bh, 0
        mov esi, Prefixes.KernelSUCCESS
        call IOPrint.Str
        
        mov esi, .progress3
        call IOPrint.Str
        
        popa
        ret
    
    .WaitW:
        in al, 0x64
        
        test al, 2
        jnz .WaitW
        ret
    
    .WaitR:
        in al, 0x64
        
        test al, 1
        jz .WaitR
        ret
    
    .progress1: db 'Setting up PS/2 controller. ', 0
    .errMsg1:   db 'Failed to test PS/2 controller.', 0
    .errMsg2:   db 'No working PS/2 ports.', 0
    .errMsg3:   db 'Unable to reset PS/2 device', 0
    .progress2: db 'Setting up PS/2 device. ', 0
    .progress3: db 'Set up PS/2 device (Keyboard). ', 0
    
    .err:
        mov bh, 0
        mov esi, Prefixes.KernelERROR
        call IOPrint.Str
        
        mov esi, .errMsg1
        call IOPrint.Str
        
        hlt
    
    .err2:
        mov bh, 0
        mov esi, Prefixes.KernelERROR
        call IOPrint.Str
        
        mov esi, .errMsg2
        call IOPrint.Str
        
        hlt
    
    .err3:
        mov bh, 0
        mov esi, Prefixes.KernelERROR
        call IOPrint.Str
        
        mov esi, .errMsg3
        call IOPrint.Str
        
        hlt
    
    .scanMap: ;db 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
              ;db 0x0, 0x0, '`', 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 'q', '1', 0x0
              ;db 0x0, 0x0, 'z', 's', 'a', 'w', '2', 0x0, 0x0, 'c', 'x', 'd'
              ;db 'e', '4', '3', 0x0, ' ', 'v', 'f', 't', 'r', '5', 0x0, 0x0
              ;db 'n', 'b', 'h', 'g', 'y', '6', 0x0, 0x0, 0x0, 'm', 'j', 'u'
              ;db '7', '8', 0x0, 0x0, ',', 'k', 'i', 'o', '0', '9', 0x0, 0x0
              ;db '.', '/', 'l', ':', 'p', '-', 0x0, 0x0, 0x0, 0x0, 0x0, '['
              ;db '=', 0x0, 0x0, 0x0, 0x0, 0x1, ']', 0x0, '\', 0x0, 0x0, 0x0
              ;db 0x0, 0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, '1', 0x0, '4', 0x0
              ;db '7', 0x0, 0x0, 0x0, '0', '8', 0x0, 0x0, 0x0, '+', '3', '-'
              ;db '*', '9'
              
              db 0x0, 0x0, '1', '2', '3', '4', '5', '6', '7', '8'
              db '9', '0', '-', '=', 0x2, 0x0, 'q', 'w', 'e', 'r'
              db 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x1, 0x0
              db 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';'
              db '`', '`', 0x0, '\', 'z', 'x', 'c', 'v', 'b', 'n'
              db 'm', ',', '.', '/', 0x0, '*', 0x0, ' '
              
              times 0x7E-($-.scanMap) db 0
    
    .Interrupt:
        pusha
        
        ;xchg bx, bx
        
        xor eax, eax
        in al, 0x60
        
        mov byte [.ScanCode], al
        
        mov edi, .scanMap
        add edi, eax
        mov al, [edi]
        
        mov [.PressedKey], al
        
        mov al, 0x20
        out 0x20, al
        
        popa
        iret
    
    .PressedKey: db 0
    .ScanCode: db 0
    
    times 5*512-($-PS_2) db 0
