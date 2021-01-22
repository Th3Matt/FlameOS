
VIDMEM equ 0xB8000
White_on_Black equ 0x0F  

global SerialDriver.init
global VDriver.clear
global VDriver.printStr

VDriver:
    .printChr:  ; Printing a single character.  Input: bx - Chr+Att.
        pusha
        
        mov ax, bx
        
        cmp al, 1
        je .newLine.1
        
        mov di, [Values.N]
        shl edi, 1          ; Calculating the location in VRAM
        add edi, VIDMEM
        
        mov [edi], bx       ; Writing to VRAM
        
        mov eax, 1
        add [Values.X], eax
        
        jmp .end
    
    .printStr:              ; Printing a 0h terminated string. Input: esi - string start address.
        pusha
        
        .loop:
            mov bl, [esi]
            
            cmp bl, 0
            je .end
            
            mov bh, White_on_Black
            
            call .printChr
            
            inc esi
            
            jmp .loop
        
    .end:
        call .Update
        
        popa
        ret
    
    .Update:
        pusha
        
        xor eax, eax
        mov [Values.N], ax
        
        
        .Update.loop:
            mov al, [Values.W]
            cmp [Values.X], al
            jnl .Update.incY
            
            .Update.loop.1:
            
            mov ah, [Values.H]
            cmp [Values.Y], ah
            jnl .Update.overflow
            
            .Update.loop.2:
            
            cmp [Values.X], al
            jnl .Update.loop
            
            mov al, [Values.X]
            add [Values.N], al
            
            xor ecx, ecx
            mov cl, [Values.Y]
            
            mov ax, 0x50
            
            .Update.loop2:
                cmp cx, 0
                je .Update.end
                
                add [Values.N], ax
                
                dec cx
                
                jmp .Update.loop2
            
            .Update.end:
            
            popa
            ret
        
        .Update.incY:
            mov ah, 0x50
            sub [Values.X], ah
            
            mov ah, 1
            add [Values.Y], ah
            
            jmp .Update.loop.1
            
        .Update.overflow:
            xor ah, ah
            mov [Values.Y], ah
            mov [Values.N], ah
            
            jmp .Update.loop.2
    
    .newLine:
        pusha
        
        mov byte [Values.X], 50h
        
        call .Update
        
        popa
        ret
        
        .newLine.1:
            mov byte [Values.X], 50h
            
            call .Update
            jmp .end
        
    .clear:
        pusha
        xor eax, eax
        xor ecx, ecx
        mov [Values.X], al
        mov [Values.Y], al
        mov bx, 0x0000
        mov ax, 0xF9E
        
        .loop4:
            mov edi, VIDMEM
            add edi, ecx
            
            mov [edi], bx
            
            add cx, 2
            
            cmp cx, ax
            jne .loop4
        
        call .Update
        popa
        ret
            
    .backspace:
        pusha
        
        mov eax, 1
        sub [Values.X], ax
        call .Update
        
        mov bx, 0000h
        call .printChr
        
        mov eax, 1
        sub [Values.X], ax
        call .Update
        
        popa
        ret
        
    .cursorSet:
        call .Update
        pusha
        
        mov di, [Values.CurN]
        shl edi, 1
        add edi, VIDMEM
        
        mov ax, 0
        mov [edi], ax
        
        mov ah, [Values.X]
        mov [Values.CurX], ah
        
        mov ah, [Values.Y]
        mov [Values.CurY], ah
        
        mov ax, [Values.N]
        mov [Values.CurN], ax
        
        popa
        ret
    
    .cursor:
        pusha
        
        mov di, [Values.CurN]
        shl edi, 1
        add edi, VIDMEM
        
        mov al, '|'
        mov ah, White_on_Black
        mov [edi], ax
        
        popa
        ret
    
    .cursorInc:
        pusha
        
        mov al, 1
        add [Values.CurX], al
        
        popa
        call .CursorUpdate
        ret
    
    .cursorDec:
        pusha
        
        mov al, 1
        sub [Values.CurX], al
        
        popa
        call .CursorUpdate
        ret
    
    .CursorUpdate:
        pusha
        
        xor eax, eax
        mov [Values.CurN], ax
        
        
        .CursorUpdate.loop:
            mov al, [Values.W]
            cmp [Values.CurX], al
            jnl .CursorUpdate.incY
            
            .CursorUpdate.loop.1:
            
            mov ah, [Values.H]
            cmp [Values.CurY], ah
            jnl .CursorUpdate.overflow
            
            .CursorUpdate.loop.2:
            
            cmp [Values.CurX], al
            jnl .CursorUpdate.loop
            
            mov al, [Values.CurX]
            add [Values.CurN], al
            
            xor ecx, ecx
            mov cl, [Values.CurY]
            
            mov ax, 0x50
            
            .CursorUpdate.loop2:
                cmp cx, 0
                je .CursorUpdate.end
                
                add [Values.CurN], ax
                
                dec cx
                
                jmp .CursorUpdate.loop2
            
            .CursorUpdate.end:
            
            popa
            ret
        
        .CursorUpdate.incY:
            mov ah, 0x50
            sub [Values.CurX], ah
            
            mov ah, 1
            add [Values.CurY], ah
            
            jmp .CursorUpdate.loop.1
            
        .CursorUpdate.overflow:
            xor ah, ah
            mov [Values.CurY], ah
            mov [Values.CurN], ah
            
            jmp .CursorUpdate.loop.2
    
    ;.cursorBlink:
        pusha
        push edi
        
        mov di, [Values.CurN]
        shl edi, 1
        add edi, VIDMEM
        
        xor ax, ax
        cmp [Values.CurV], ax
        inc ax
        je .cursorBlink.1
        
        sub [Values.CurV], ax
        
        xor ax, ax
        mov [edi], ax
        
        .cursorBlink.end:
        
        pop edi
        popa
        ret
        
        .cursorBlink.1:
            add [Values.CurV], ax
            
            mov al, '|'
            mov ah, White_on_Black
            mov [edi], ax
            
            jmp .cursorBlink.end
    
    .HEXTEMPLATE: db '0x0000', 0
    .HEXTable: dw '0123456789ABCDEF'
    
    .printHex:
        pusha
        
        mov bx, cx
        shr bx, 12
        mov bl, [.HEXTable + bx]
        mov [.HEXTEMPLATE+2], bl
        
        mov bx, cx
        shr bx, 8
        and bx, 0fh
        mov bl, [.HEXTable + bx]
        mov [.HEXTEMPLATE+3], bl
        
        mov bx, cx
        shr bx, 4
        and bx, 0fh
        mov bl, [.HEXTable + bx]
        mov [.HEXTEMPLATE+4], bl
        
        mov bx, cx
        and bx, 0fh
        mov bl, [.HEXTable + bx]
        mov [.HEXTEMPLATE+5], bl
        
        mov esi, .HEXTEMPLATE
        call .printStr
        
        popa
        ret
    
    .32bitTag:
        pusha
        mov ecx, 50h
        mov esi, PMText
        mov ah, 0x8f
        mov edi, VIDMEM+0x77f
        
        .32bitTag.loop:
            cmp ecx, 0
            je .32bitTag.end
            
            mov ah, [esi]
            mov [edi], ah
            
            add edi, 2
            dec ecx
            
            cmp ah, 0
            je .32bitTag.loop
            
            inc esi
            
            jmp .32bitTag.loop
        
        .32bitTag.end:
            popa
            ret
SerialDriver:
    COM1Port equ 0x3f8
    .init:
        pusha
        
        mov dx, COM1Port
        inc dx
        mov al, 0x00
        out dx, al
        
        add dx, 2
        in al, dx
        or al, 10000000b
        out dx, al
        
        sub dx, 3
        mov al, 2
        out dx, al
        
        inc dx
        mov al, 0
        out dx, al
        
        add dx, 2
        in al, dx
        and al, 01101011b
        or al, 00101011b
        out dx, al
        
        sub dx, 2
        mov al, 00001111b
        out dx, al
        
        popa
        ret
    
    .send:
        pusha
        
        .send.Wait:
            mov dx, COM1Port+5
            in al, dx
            test al, 5
            jz .send.Wait
        
        mov dx, COM1Port
        mov al, bl
        out dx, al
        
        popa
        ret
    
    .get:
        pusha
        
        .get.Wait:
            mov dx, COM1Port+5
            in al, dx
            test al, 0
            jz .get.Wait
        
        mov dx, COM1Port
        mov al, bl
        in al, dx
        
        popa
        ret
    
    .sendStr:
        pusha
        
        .sendStr.loop:
            lodsb
            
            cmp al, 0
            je .sendStr.end
            
            mov bl, al
            call .send
            
            jmp .sendStr.loop
        
        .sendStr.end:
            popa
            ret
    
    .HEXTEMPLATE: db '0x0000', 0
    .HEXTable: dw '0123456789ABCDEF'
    
    .sendHex:
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
        call .sendStr
        
        popa
        ret

PS_2Driver:
    
    .init:
        pusha
        
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
        
        call VDriver.newLine
        
        mov esi, .progress
        call VDriver.printStr
        
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
        
        mov bh, al
        
        call .WaitR
        in al, 0x60
        mov ah, bh
        mov [Values.A], ax
        
        mov cx, [Values.A]
        call VDriver.printHex
        
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
    
    .errMsg1: db 'Failed to test PS/2 controller.', 0
    .errMsg2: db 'No working PS/2 ports.', 0
    .errMsg3: db 'Unable to reset PS/2 device', 0
    .progress: db 'Sending commands to PS/2 device ', 0
    
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
              
              times 0x7E-($$-.scanMap) db 0
    
    .keyboardInput:
        cmp al, 1
        jl .end
        je .enter
        
        cmp al, 2
        je .backspace
        
        mov edi, Values.keyboardBufferPos
        xor ebx, ebx
        mov bl, [edi]
        mov edi, ebx
        add edi, Values.keyboardBuffer
        
        cmp byte [edi], 1
        je .end
        
        mov [edi], al
        
        add byte [Values.keyboardBufferPos], 1
        
        mov bx, ax
        mov bh, White_on_Black
        call VDriver.printChr
        
        call VDriver.cursorInc
        call VDriver.cursor
        
        .end:
            ret
        
        .enter:
            pusha
            call .commandHandler
            popa
            
            call VDriver.newLine
            
            mov esi, FSH
            call VDriver.printStr
            
            call VDriver.cursorSet
            call VDriver.cursor
            
            mov byte [Values.keyboardBufferPos], 0
            
            jmp .end
        
        .backspace:
            cmp byte [Values.keyboardBufferPos], 0
            je .end
            
            call VDriver.backspace
            
            call VDriver.cursorSet
            call VDriver.cursor
            
            mov edi, Values.keyboardBufferPos
            sub byte [edi], 1
            
            jmp .end
        
        .commandHandler:
            call VDriver.newLine
            
            mov edi, Values.keyboardBuffer
            
            mov esi, Commands.echo.name
            
            call .chkifcorrect
            
            cmp byte [Values.correct], 0
            jne Commands.echo
            
            mov esi, .CMDErrPrefix
            call VDriver.printStr
            
            mov esi, .CMDErr1
            call VDriver.printStr
            
            ret
            
            .chkifcorrect:
                pusha
                
                .chkifcorrect.start:
                    
                    mov al, [edi]
                    mov bl, [esi]
                    
                    cmp al, bl
                    
                    je .chkifcorrect.inc
                
                .chkifcorrect.end:
                    mov byte [Values.correct], 1
                    inc edi
                    
                    sub edi, Values.keyboardBuffer
                    
                    xor eax, eax
                    mov eax, edi
                    
                    mov [Values.keyboardBufferPos], al
                    
                    cmp bl, 0
                    
                    je .chkifcorrect.ret
                    
                    mov byte [Values.correct], 0
                
                .chkifcorrect.ret:
                    popa
                    ret
                
                .chkifcorrect.inc:
                    inc edi
                    inc esi
                    
                    jmp .chkifcorrect.start
                    
        
        .CMDErrPrefix: db 'FSH: ', 0
        .CMDErr1: db 'No such command or program.', 0

ATA_Driver:
    
    ATA1Port equ 0x1F0
    
    .init:
        pusha
        
        mov dx, ATA1Port+7
        in al, dx
        
        cmp al, 0xff
        je .noDisk
        
        mov dx, ATA1Port+6
        mov al, 0xA0
        out dx, al
        
        inc dx
        
        mov cx, 5
        
        rep in al, dx
        
        mov dx, ATA1Port+5
        
        mov al, 0
        out dx, al
        
        dec dx
        out dx, al
        
        dec dx
        out dx, al
        
        dec dx
        out dx, al
        
        dec dx
        out dx, al
        
        mov dx, ATA1Port+7
        mov al, 0xEC
        out dx, al
        
        in al, dx
        
        cmp al, 0
        jne .diskFound
        
        test al, 0
        jnz .packetedATA
    
    .noDisk:
        mov byte [Values.ATADriverStatus], 1
        
        ret
    
    .packetedATA:
        jmp .noDisk
    
    .diskFound:
        in al, dx
        
        test al, 7
        jnz .diskFound
        
        mov dx, ATA1Port+4
        in al, dx
        
        cmp al, 0
        jne .packetedATA
        
        inc dx
        
        cmp al, 0
        jne .packetedATA
        
        .diskFound.1:
            in al, dx
            
            test al, 0
            jnz .diskError
            
            test al, 3
            jnz .diskFound.2
            
            jmp .diskFound.1
        
        .diskFound.2:
        
        mov dx, ATA1Port
        mov es, 0x10
        mov di, Values.sectorBuffer
        mov cx, 256
        
        rep insw
        
        mov byte [Values.ATADriverStatus], 2
        
        ret
    
    .writeSector:
        pusha
        
        mov dx, ATA1Port+2
        mov al, 1
        
        out dx, al
        
        inc dx
        
        out dx, al
        
        inc dx
        mov al, 0
        
        out dx, al
        
        inc dx
        
        out dx, al
        
        mov dx, ATA1Port+7
        mov al, 30h
        
        out dx, al
        
        mov esi, ebx
        mov cx, 256
        mov dx, ATA1Port
        
        rep outsw
        
        popa
        ret
    
    ;.readSectors:
    ;    pusha
    ;    
    ;    mov dx, ATA1Port+6
    ;    mov al, 00010000b
    ;    out dx, al
    ;    
    ;    mov dx, ATA1Port+4
    ;    mov al, 0
    ;    out dx, al
    ;    
    ;    inc dx
    ;    mov al, 2
    ;    out dx, al
    ;    
    ;    mov dx, ATA1Port+7
    ;    mov al, 0xA0
    ;    out dx, al
    ;    
    ;    mov byte [.keyboardBuffer]
    ;    
    ;    sti
    ;    
    ;    .readSectors.wait:
    ;        cmp byte [Values.ATADriverStatus], 2
    ;        jne .readSectors.wait
    ;    
    ;    cli
    ;    
    ;    mov byte [Values.ATADriverStatus], 0
    ;    
    ;.DiskIRQ:
    ;    mov byte [.ATADriverStatus], 2
    ;    ret
    
Values:
    .keyboardBuffer:
        resb 40
        db 0x1
        db 0
    
    .A: dw 0x00
    
    .X: dd 0x00 ; Characters X
    .Y: dd 0x00 ; Characters Y
    .N: dw 0x0000 ; Characters # (X + Y*80)
    
    .W: dd 0x50 ; Screen width
    .H: dd 0x18 ; Screen height
    
    .CurX: dd 0x00
    .CurY: dd 0x00
    .CurN: dw 0x0000
    .CurV: dd 0b
    
    .keyboardBufferPos: db 0
    
    .correct: db 0
    
    .keyboardFlag: db 0
    
    .ATADriverStatus: db 0
    
    .sectorBuffer:
        resb 512
