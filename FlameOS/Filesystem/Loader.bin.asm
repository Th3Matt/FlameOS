
Loader:
    
    mov dx, 0x3DA
    in al, dx
    mov dx, 0x3C0
    mov al, 0x30
    out dx, al
    inc dx
    in al, dx
    and al, 0xF7
    dec dx
    out dx, al  
    
    mov esi, DescriptorSectors+64+1
    mov al, [esi]
    add al, [InfoSector+7]
    add al, 12
    inc esi
    mov cl, [esi]
    mov edi, IOPrint
    
    call ATA.ReadSectors
    
    call IOPrint.Clear
    call IOPrint.ClearShellALL
    
    xchg bx, bx
    
    mov edx, 0
    
    mov bh, 0
    mov esi, .STR1
    call IOPrint.Str
    
    ;xchg bx, bx
    
    mov ax, 80-(.STR3-.STR2)
    call IOPrint.SetXY
    
    mov esi, .STR2
    call IOPrint.Str
    
    ;xchg bx, bx
    
    mov ax, 071Eh
    call IOPrint.SetXY
    
    mov bh, 04h
    mov esi, .F1
    call IOPrint.Str
    
    mov ax, 081Eh
    call IOPrint.SetXY
    
    mov esi, .F2
    call IOPrint.Str
    
    mov ax, 091Eh
    call IOPrint.SetXY
    
    mov esi, .F3
    call IOPrint.Str
    
    mov ax, 0A1Eh
    call IOPrint.SetXY
    
    mov esi, .F4
    call IOPrint.Str
    
    mov ax, 0B1Eh
    call IOPrint.SetXY
    
    mov esi, .F5
    call IOPrint.Str
    
    mov ax, 0C1Eh
    call IOPrint.SetXY
    
    mov bh, 04h
    mov esi, .F6
    call IOPrint.Str
    
    mov ax, 0D1Eh
    call IOPrint.SetXY
    
    mov bh, 0Eh
    mov esi, .F7
    call IOPrint.Str
    
    ;xchg bx, bx
    
    mov bl, 2
    call IOPrint.SetXY
    call IOPrint.SetXY
    
    mov esi, DescriptorSectors+64*3+1
    mov al, [esi]
    add al, [InfoSector+7]
    add al, 12
    inc esi
    mov cl, [esi]
    mov edi, Shell
    
    call ATA.ReadSectors
    
    xchg bx, bx
    
    jmp Shell
    
    .STR1: db 'FlameLoader loaded.', 0
    .STR2: db 'Installed Version: 0.0.1', 0
    .STR3: db 'Starting FlameShell...', 0
    
    .F1: db '        /\          ', 0           ; X 20 Y 7
    .F2: db '       ,\`\    ,    ', 0
    .F3: db '      /\/``\  /|    ', 0
    .F4: db '     /`    `|/`|    ', 0
    .F5: db '     \.     ``./    ', 0
    .F6: db '      `~~~~~~~`     ', 0
    .F7: db '       FlameOS      ', 0
    
    times 2*512-($-Loader) db 0
    
