
VIDMEM            equ 0x000B8000
ShellTextLoc      equ 0x00020FA0
ShellBGLoc        equ 0x00020000
DirectLoc         equ 0x00021F40

IOPrint:
    .Chr:
        pusha
        push edx
        
        xor edx, edx
        xor ecx, ecx
        mov dl, bl
        mov cl, bh
        
        .Chr.1: 
            cmp cl, 0
            je .Chr.2
            add edx, 80
            dec cx
            
            jmp .Chr.1
        
        .Chr.2:
        
        shl edx, 1
        mov ebx, edx
        
        pop edx
        
        mov edi, ShellBGLoc
        
        cmp edx, 1
        jl .Chr.3
        
        mov edi, ShellTextLoc
        
        cmp edx, 2
        jl .Chr.3
        
        mov edi, DirectLoc
        
        .Chr.3:
        add edi, ebx
        
        mov [edi], ax
        
        popa
        ret
    
    .Str:
        pusha
        xor ecx, ecx
        
        mov ah, bh
        
        cmp bh, 0
        jne .Str.loop
        
        mov ah, 0fh
        
        .Str.loop:
            call .Update
            
            cmp byte [esi], 0
            je .Str.end
            
            mov al, [esi]
            
            mov bl, [.X]
            mov bh, [.Y]
            
            call .Chr
            
            inc byte [.X]
            inc esi
            
            jmp .Str.loop
        
        .Str.end:
            popa
            ret
    
    .Update:
        cmp byte [.X], 0x50
        je .Update.incY
        
        cmp byte [.Y], 23
        jnl .Update.2
        
        ret
        
        .Update.2:
        
        ;xchg bx, bx
        
        mov ecx, 3
        call .Scroll
        
        sub byte [.Y], 3
        mov al, [.X]
        mov di, ax
        mov cl, [.Y]
        
        .YLoop:
            dec cl
            add di, 80
            
            cmp cl, 0
            jne .YLoop
        
        dec di
        shl di, 1
        mov [Shell.ShellOffset], di
    
        
        ret
        
        .Update.incY:
            inc byte [.Y]
            sub byte [.X], 50h
            jmp .Update
    
    .SetXY:
        cmp bl, 1
        jl .SetXY.set
        je .SetXY.incX
        cmp bl, 2
        je .SetXY.incY
        ret
        
        .SetXY.incY:
            inc byte [.Y]
            mov byte [.X], 0
            jmp .SetXY.end
        
        .SetXY.incX:
            inc byte [.X]
            jmp .SetXY.end
        
        .SetXY.set:
            mov [.X], al
            mov [.Y], ah
        
        .SetXY.end:
            call .Update
            ret
    
    .X: db 0
    .Y: db 0
    
    .Clear:
        mov esi, VIDMEM
        mov ecx, 3E8h
        
        .Clear.1:
            mov dword [esi], 0
            add esi, 4
            
            loop .Clear.1
        
        ret
    
    .Scroll:
        pusha
        
        .Scroll.1:
        
        push ecx
        
        mov edi, ShellTextLoc
        mov esi, ShellTextLoc+80*2
        mov ecx, 25*20*2
        
        .Scroll.loop:
            mov eax, [esi]
            mov [edi], eax
            
            add edi, 4
            add esi, 4
            
            loop .Scroll.loop
        
        mov ecx, 10
        
        .Scroll.loop2:
            mov byte [edi], 0
            
            inc edi
            
            loop .Scroll.loop2
        
        pop ecx
        
        loop .Scroll.1
        
        popa
        ret
    
    .ClearShellALL:
        pusha
        
        mov edi, ShellBGLoc
        mov ecx, 25*20*2*3
        
        .ClearShellALL.loop:
            mov dword [edi], 0
            
            add edi, 4
            
            loop .ClearShellALL.loop
        
        popa
        ret
    
    .ClearShell:
        pusha
        
        mov edi, ShellTextLoc
        mov ecx, 25*20*2
        
        .ClearShell.loop:
            mov dword [edi], 0
            
            add edi, 4
            
            loop .ClearShell.loop
        
        popa
        ret
    
    
    times 3*512-($-IOPrint) db 0

