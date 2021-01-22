 
Commands:
    .echo:
        mov esi, .echo.text
        call VDriver.printStr
        
        mov esi, Values.keyboardBuffer
        xor eax, eax
        mov al, [Values.keyboardBufferPos]
        add esi, eax
        call VDriver.printStr
        
        ret
        
        .echo.text: db 'echo: ', 0
        .echo.name: db 'echo', 0
    
    .diskSetUp:
        call ATA_Driver.init
        
        cmp byte [Values.ATADriverStatus], 1
        je .diskSetUp.noDisk
        
        mov esi, .diskSetUp.foundDisk
        call VDriver.printStr
        
        mov esi, .diskSetUp.foundDisk2
        call VDriver.printStr
        
        mov byte [Values.keyboardFlag], 1
        
        sti
        
        .diskSetUp.acceptable:
            cmp byte [Values.keyboardBuffer], 0
            je .diskSetUp.acceptable
            
            cmp byte [Values.keyboardBuffer], 'Y'
            je .diskSetUp.format
            
            cmp byte [Values.keyboardBuffer], 'N'
            je .diskSetUp.end
            
            call VDriver.backspace
            jmp .diskSetUp.acceptable
            
        
        .diskSetUp.format:
            ;cli
            
            ;mov ah, 0
            ;mov al, 1
            
            ;call ATA_Driver.readSectors
            
            mov ebx, 0x7c00
            
            call ATA_Driver.writeSector
            
            
        
        .diskSetUp.foundDisk: db 'Disk found at ATA1 Master port.', 1, 0
        .diskSetUp.foundDisk2: db 'Format this disk? ', 0
        .diskSetUp.name: db 'disk-setup', 0
