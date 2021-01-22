 
Text_edit:
    pusha
    
    mov byte [Shell.GraphicsType], 1
    
    mov edi, Shell.ScreenRedraw
    call edi
    
    mov edi, IOPrint.SetXY
    mov bl, 0
    xor ax, ax
    call edi
    
    mov edi, IOPrint.Str
    mov edx, 2
    mov bh, 8Fh
    mov esi, 0x30000+Text_edit2.new-Text_edit
    call edi
    
    mov edi, IOPrint.SetXY
    mov bl, 0
    xor ax, ax
    mov al, 80-(Text_edit2.end-Text_edit2.PrgName)
    call edi
    
    mov edi, IOPrint.Str
    mov edx, 2
    mov esi, 0x30000+Text_edit2.PrgName-Text_edit
    call edi
    
    mov edi, IOPrint.SetXY
    mov bl, 0
    mov ah, 2
    mov al, 4
    call edi
    
    xor ax, ax
    mov [0x30000+Text_edit2.CursorX-Text_edit2], al
    mov [0x30000+Text_edit2.CursorY-Text_edit2], al
    
    mov al, [IOPrint.X]
    mov di, ax
    mov cl, [IOPrint.Y]
    
    .YLoop:
        dec cl
        add di, 80
        
        cmp cl, 0
        jne .YLoop
    
    dec di
    shl di, 1
    mov [0x30000+Text_edit2.Start-Text_edit2], di
    
    mov ah, 0x0F
    mov al, '/'
    
    mov bl, [IOPrint.X]
    mov bh, [IOPrint.Y]
    
    mov edi, IOPrint.Chr
    call edi
    
    mov dword [Shell.GraphicsBuffer], DataFile1
    mov ax, [0x30000+Text_edit2.Start-Text_edit2]
    mov word [Shell.GraphicsBufferOffset], ax

    mov edi, Shell.ScreenRedraw
    call edi
    
    
    
    jmp $
    
    popa
    ret
    
    times 9*512-($-Text_edit) db 0
    
Text_edit2:
    .new: db 'new'
          times 80-($-.new) db ' '
          db 0
    .PrgName: db 'TextEdit', 0
    
    .end:
    
    .Start: dw 0
    .CursorX: db 0
    .CursorY: db 0
    
    times 512-($-Text_edit2) db 0
