
IODisk:
    .loadFile:
        pusha
        
        ;sub [eax], byte 
        
        xchg bx, bx
        
        push edi
        
        mov edi, DescriptorSectors+3
        
        xor eax, eax
        xor ecx, ecx
        mov cl, [InfoSector+7]
        
        .loadFile.loopMultiply:
            add eax, 512
            
            loop .loadFile.loopMultiply
        
        xor ecx, ecx
        
        .loadFile.loop:
            push eax
            
            mov al, [edi]
            
            cmp al, 0
            je .loadFile.done
            
            cmp [esi], al
            je .loadFile.found
            
            sub esi, ecx
            sub edi, ecx
            xor ecx, ecx
            
            add edi, 64
            
            mov edx, edi
            sub edx, DescriptorSectors
            
            pop eax
            
            cmp edx, eax
            
            jnl .loadFile.end
            
            jmp .loadFile.loop
            
        .loadFile.found:
            inc ecx
            inc esi
            inc edi
            
            pop eax
            
            jmp .loadFile.loop
        
        .loadFile.done:
            pop eax
            
            cmp ecx, 0
            je .loadFile.end
            
            mov al, [esi]
            
            cmp al, 0
            jne .loadFile.end
            
            sub edi, ecx
            sub edi, 2
            mov esi, edi
            mov al, [esi]
            add al, [InfoSector+7]
            add al, 12
            inc esi
            mov cl, [esi]
            pop edi
            
            xchg bx, bx
            
            call .ReadSectors
            
            clc
            popa
            ret
        
        .loadFile.end:
            stc
            pop edi
            popa
            ret
    
    .ReadSectors:  ; edi - buffer location, ax - sector location, cx - ammount of sectors.
        pusha
        push cx
        push ax
        
        mov dx, ATA1Port+2
        mov al, cl
        
        out dx, al
        
        inc dx
        
        pop ax
        out dx, al
        
        inc dx
        mov al, 0
        
        out dx, al
        
        inc dx
        
        out dx, al
        
        mov dx, ATA1Port+7
        mov al, 20h
        
        out dx, al
        
        call .IOWait
        
        nop
        nop
        
        .ReadSectors.1:
            mov ecx, 256
            mov dx, ATA1Port
            
            rep insw
            
            test al, 0x21
            jz .ReadSectors.fail
            
            pop cx
            dec cx
            push cx
            
            cmp cx, 0
            jne .ReadSectors.1
        
        pop cx
        popa
        ret
        
        .ReadSectors.fail:
            mov dx, ATA1Port+1
            in al, dx
            
            and ax, 00ffh
            mov bx, ax
            mov ax, 0
            call Print.Hex
            
            jmp $
    
    .IOWait:
        pusha
        mov dx, ATA1Port+7
        
        .IOWait.loop:
            in al, dx
            
            test al, 0
            jnz ATA.init.noDisk
            
            test al, 3
            jz .IOWait.loop
            
            test al, 6
            jz .IOWait.loop
            
            test al, 7
            jz .IOWait.loop
        
        popa
        ret

    
    times 5*512-($-IODisk) db 0
