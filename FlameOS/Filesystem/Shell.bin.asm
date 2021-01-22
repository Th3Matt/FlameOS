
MaxChrsShell      equ         40
KeyboardBufferLoc equ 0x00000000
Program1          equ 0x00030000
DataFile1         equ 0x00035000

Shell:
    xchg bx, bx
    
    mov esi, DescriptorSectors+64*4+1
    mov al, [esi]
    add al, [InfoSector+7]
    add al, 12
    inc esi
    mov cl, [esi]
    mov edi, PS_2
    
    call ATA.ReadSectors
    
    mov esi, DescriptorSectors+64*2+1
    mov al, [esi]
    add al, [InfoSector+7]
    add al, 12
    inc esi
    mov cl, [esi]
    mov edi, IODisk
    
    call ATA.ReadSectors
    
    mov edi, Program1
    mov ecx, 0xC000
    xor eax, eax
    
    xchg bx, bx
    rep stosd
    
    xchg bx, bx
    
    call PS_2.init
    
    xchg bx, bx
    
    call .setPIC
    
    mov al, 11111101b
    out 0x21, al
    
    mov al, 11111111b
    out 0xA1, al
    
    mov edi, .IDT+8*0xD
    mov eax, ExceptionH.GPF
    
    call .IDTEntry
    
    mov edi, .IDT+8*0x21
    mov eax, PS_2.Interrupt
    
    call .IDTEntry
    
    lidt [.IDTR]
    lgdt [.GDTR]
    
    mov bl, 2
    call IOPrint.SetXY
    call IOPrint.SetXY
    
    mov bh, 0
    mov edx, 1
    mov esi, .STR1
    call IOPrint.Str
    
    ;jmp 0x8:.debug
    ;.debug:
    
    .SettingShellOffset:
    
    xor ax, ax
    mov [.CursorX], al
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
    mov [.ShellOffset], di
    
    mov edi, 0
    mov ecx, 40
    call .BufferClear
    
    
    mov byte [Shell.GraphicsType], 0
    call .ScreenRedraw
    
    .ShellLoop:
        sti
        cmp byte [PS_2.PressedKey], 0
        je .ShellLoop
        
        cli
        call .ShellInput
        call .ScreenRedraw
        
        ;xchg bx, bx
        
        cmp byte [PS_2.ScanCode], 25
        jg .ShellLoop
        
        call .Ignore
        jmp .ShellLoop
    
    .Ignore:
        cmp byte [PS_2.ScanCode], 20
        je .Ignore.1
        
        cmp byte [PS_2.ScanCode], 21
        je .Ignore.1
        
        cmp byte [PS_2.ScanCode], 16
        jnl .Ignore.2
        
        cmp byte [PS_2.ScanCode], 6
        je .Ignore.end
        
        cmp byte [PS_2.ScanCode], 7
        je .Ignore.end
        
        cmp byte [PS_2.ScanCode], 11
        je .Ignore.end
        
        cmp byte [PS_2.ScanCode], 14
        je .Ignore.2
        
        cmp byte [PS_2.ScanCode], 2
        jnl .Ignore.1
        
        .Ignore.end:
            ret;   
        
        
        .Ignore.1:
            cmp byte [PS_2.ScanCode], 12
            jng .Ignore.2
            
            ret
        
        .Ignore.2:
            sti
            cmp byte [PS_2.PressedKey], 0
            je .Ignore.2
            cli
            
            mov byte [PS_2.PressedKey], 0
            ret
    
    .BufferClear:
        pusha
        
        .BufferClear.loop:
            mov byte [edi], 0
            inc edi
            
            loop .BufferClear.loop
        
        .BufferClear.end:
            popa
            ret
    
    .ShellInput:
        mov al, byte [PS_2.PressedKey]
        
        push ax
        
        mov edi, KeyboardBufferLoc
        xor eax, eax
        mov al, [.CursorX]
        add di, ax
        
        pop ax
        
        cmp al, 2
        jl .ShellInput.enter
        je .ShellInput.backspace
        
        cmp byte [.CursorX], MaxChrsShell
        je .ShellInput.end
        
        mov [edi], al
        
        inc byte [.CursorX]
        
        .ShellInput.end:
            mov byte [PS_2.PressedKey], 0
            
            ret
        
        .ShellInput.enter:
            ;xchg bx, bx
            
            dec byte [IOPrint.X]
            
            mov esi, 0
            mov bh, 0
            mov edx, 1
            call IOPrint.Str
            
            mov bl, 2
            call IOPrint.SetXY
            
            mov edi, Program1
            xor esi, esi
            call 0x00003c1e
            
            jc .ShellInput.fail
            
            call edi
            jmp .ShellInput.pastFail
            
            .ShellInput.fail:
                mov esi, Prefixes.FSHPrefix
                call IOPrint.Str
                
                mov esi, .Invalid
                call IOPrint.Str
            
            .ShellInput.pastFail:
            
            mov bl, 2
            call IOPrint.SetXY
            
            mov esi, .STR1
            call IOPrint.Str
            
            mov byte [PS_2.PressedKey], 0
            
            sti
            
            pop eax
            jmp .SettingShellOffset
        
        .ShellInput.backspace:
            cmp byte [.CursorX], 0
            je .ShellInput.end
            
            dec edi
            
            dec byte [.CursorX]
            
            mov byte [edi], 0
            
            jmp .ShellInput.end
        
    .Invalid: db 'Invalid command or filename.', 0
    
    .ScreenRedraw:
        pusha
        
        call IOPrint.Clear
        
        cmp byte [.GraphicsType], 1
        jnl .ScreenRedraw.DirectGraphics
        
        mov cx, 0xFA0
        mov edi, VIDMEM
        mov esi, ShellBGLoc
        
        .ScreenRedraw.loop1:
            mov ax, [esi]
            mov [edi], ax
           
            add esi, 2
            add edi, 2
            
            loop .ScreenRedraw.loop1
        
        mov cx, 0xFA0
        mov edi, VIDMEM
        mov esi, ShellTextLoc
        
        .ScreenRedraw.loop2:
            mov ax, [esi]
            
            cmp ax, 0
            je .ScreenRedraw.loop2.1
            
            mov [edi], ax
            
            .ScreenRedraw.loop2.1:
            
            add esi, 2
            add edi, 2
            
            loop .ScreenRedraw.loop2
        
        mov cx, 40
        mov edi, VIDMEM
        add di, [.ShellOffset]
        mov esi, KeyboardBufferLoc
        
        .ScreenRedraw.loop3:
            mov al, [esi]
            mov ah, 0x0f
            mov [edi], ax
            
            inc esi
            add edi, 2
            
            loop .ScreenRedraw.loop3
        
        mov edi, VIDMEM
        add di, [.ShellOffset]
        xor eax, eax
        mov al, [.CursorX]
        shl ax, 1
        add edi, eax
        
        mov byte [edi], '/'
        
        popa
        ret
        
        .ScreenRedraw.DirectGraphics:
            mov cx, 0xFA0
            mov edi, VIDMEM
            mov esi, DirectLoc
            
            .ScreenRedraw.loop4:
                mov ax, [esi]
                mov [edi], ax
                
                add esi, 2
                add edi, 2
                
                loop .ScreenRedraw.loop4
            
            cmp dword [.GraphicsBuffer], 0
            je .ScreenRedraw.loop5.end
            
            mov cx, 0xFA0
            mov edi, [.GraphicsBufferOffset]
            add edi, VIDMEM
            mov esi, .GraphicsBuffer
            
            .ScreenRedraw.loop5:
                mov ax, [esi]
                mov [edi], ax
                
                add esi, 2
                add edi, 2
                
                loop .ScreenRedraw.loop5
            
            .ScreenRedraw.loop5.end:
            
            popa
            ret
        
    
    .ShellOffset:          dw 0
    .CursorX:              db 0
    .GraphicsType:         db 0
    .GraphicsBuffer:       dd 0
    .GraphicsBufferOffset: dw 0
    
    .STR1: db '{>FlameShell<}  /', 0
    
    .IDT:
        
        times 8*256-($-.IDT) db 0
    .IDTR:
        dw .IDT-.IDTR-1
        dd .IDT
    
    .IDTEntry:
        mov [edi], ax
        
        shr eax, 16
        push ax
        
        add edi, 2
        
        mov ax, 0x8
        mov [edi], ax
        
        add edi, 2
        
        mov al, 0
        mov ah, 10001110b
        mov [edi], ax
        
        add edi, 2
        
        pop ax
        mov [edi], ax
        
        add edi, 2
        
        ret
    
    .GDT:
        .GDT.null:
            dq 0
        
        .GDT.code:
            dw 0FFFFh
            dw 0
            
            db 0
            db 010011010b
            db 011011111b
            db 0
        
        .GDT.data:
            dw 0FFFFh
            dw 0
            
            db 0
            db 010010010b
            db 011011111b
            db 0
    
    .GDTR:
        dw .GDT-.GDTR-1
        dd .GDT
    
    .setPIC:
        mov al, 0x11
        out 0x20, al
        
        mov al, 0x11
        out 0xA0, al
        
        mov al, 0x20
        out 0x21, al
        
        mov al, 0x28
        out 0xA1, al
        
        mov al, 0x04
        out 0x21, al
        
        mov al, 0x02
        out 0xA1, al
        
        mov al, 0x01
        out 0x21, al
        
        mov al, 0x01
        out 0xA1, al
        
        mov al, 0x00
        out 0x21, al
        
        mov al, 0x00
        out 0xA1, al
        
        ret

    ExceptionH:
        .GPF:
            cli
            pusha
            
            mov bl, 2
            call IOPrint.SetXY
            
            xor ebx, ebx
            mov esi, .GPFText
            call IOPrint.Str
            
            popa
            sti
            
            iret
        
        .GPFText: db '[ EXCEPT  ]  General Protection Fault occured, continuing.', 0
    
    Prefixes:
        .KernelINFO: db '[ INFO    ]  ', 0
        .KernelERROR: db '[ ERROR   ]  ', 0
        .KernelSUCCESS: db '[ SUCCESS ]  ', 0
        
        .FSHPrefix: db ' FlameShell:  ', 0
    
    times 48*512-($-Shell) db 0
