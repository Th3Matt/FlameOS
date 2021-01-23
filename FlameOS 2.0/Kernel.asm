
GDTTableLoc equ 0x13A00
IDTTableLoc equ GDTTableLoc-0x1500-0x64+0xFA
ErrorBackground equ 0x6

    [ BITS 32 ]
    [ ORG 0x0 ]

KernStart:
    xchg bx, bx
    
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov sp, 0x1500

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
    
    mov edi, 0x500
    
    .Clear:				; Clearing space for some data structures.
        mov dword [edi], 0
        add edi, 4
        
        cmp edi, 0x14600
        jl .Clear
    
    mov byte [0x15A00], 00000011b
    mov byte [0x15A01], 0
    mov dword [0x15A02], 0
    
    xchg bx, bx
    mov edi, 0x16000
    mov esi, 0x14600+Strings.Panic1
    mov ecx, (80*2)
    mov ah, 0xC

    .Clear2:				; Writing the kernel panic screen to "Cached Screens"...
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear2
    
    xchg bx, bx
    mov ecx, (80*3)
    mov ah, 0x0+(ErrorBackground<<4)

    .Clear3:				; ...Writing some more of it in a different color...
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear3
    
    mov ecx, (80*18)
    mov ah, 0xF+(ErrorBackground<<4)

    .Clear4:				; ... and again ...
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear4
    
    mov ecx, (80*2)
    mov ah, 0xC
    
    .Clear5:				; ... and again.
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear5
    
    mov ecx, 8
    add edi, 0xFA0
    xchg bx, bx

    .Clear6:				; Adding a Hex conversion table
        mov ax, [esi]
        mov word [edi], ax
        add edi, 2
        add esi, 2
        
        loop .Clear6
    
    mov dword [1500+0x03], 0x1000
    
    mov word [1500+0x07], 0x8
    
    mov word [1500+0x62], 0x64

    xchg bx, bx
    					; Setting up GDT...
		    ;---------------------00 - NULL
    mov edi, GDTTableLoc
    mov dword [edi], 0
    add edi, 4
    mov dword [edi], 0
    add edi, 4
                    ;---------------------08 - Stack
		    ;500 - 1500
    mov ax, 0x14ff
    mov [edi], ax
    
    add edi, 2
    
    push ax
    mov ax, 0x500
    mov [edi], ax
    pop ax
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010000b
    shl ecx, 8
    mov ch, 10010010b
    mov [edi], ecx
    
    add edi, 4
                    ;---------------------10 - TSS
		    ;1500 - 1564
    add ax, 0x65
    mov word [edi], 0x64
    
    add edi, 2
    push ax
    
    sub ax, 0x64
    mov [edi], ax
    
    pop ax    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 0x40
    shl ecx, 8
    mov ch, 0x89
    mov [edi], ecx
    
    add edi, 4
   		    ;----------------------18 - Kernel Data
		    ;1565 - 145ff
    add ax, 0x4600-0x64-0x1500-1
    mov [edi], ax
    
    add edi, 2
    push ax
    sub ax, 0x4600-0x64-0x1500-2
    mov [edi], ax
    pop ax
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10010010b
    mov [edi], ecx
    
    add edi, 4
    
    inc ax
    mov bx, ax      ;---------------------20 - Kernel Code
		    ;14600 - 159ff
    add ax, 0x13FF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10011010b
    mov cl, 1
    mov [edi], ecx
    
    add edi, 4      ;---------------------28 - Screen - Stored in GS.
    		    ;b8000 - bffff
    mov bx, 0x8000
    mov ax, 0xFFFF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01011011b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0xB
    mov [edi], ecx
    
    add edi, 4      ;---------------------30 - Hookpoints
		    ;14300 - 145ff
    
    mov bx, 0x4300
    mov ax, 0x45ff
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0x1
    mov [edi], ecx
    
    add edi, 4      ;---------------------38 - VidBuffer Pointers - AKA Locations of cached screens.
		    ;15a00 - 15fff
    
    mov bx, 0x5A00
    mov ax, 0x5FFF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0x1
    mov [edi], ecx
    
    add edi, 4      ;---------------------40 - USER Data
		    ;100000 - ffffffff
    
    mov bx, 0x0000
    mov ax, 0xFFFF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 11011111b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0x10
    mov [edi], ecx
    
    add edi, 4      ;---------------------48 - USER Code
		    ;100000 - ffffffff
    
    mov bx, 0x0000
    mov ax, 0xFFFF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 11011111b
    shl ecx, 8
    mov ch, 10011010b
    mov cl, 0x10
    mov [edi], ecx
    
    add edi, 4      ;---------------------50 - Cached system screens.
		    ;16000 - 16F9F
    
    mov bx, 0x6000
    mov ax, 0x7F3f
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0x1
    mov [edi], ecx
    
    add edi, 4      ;---------------------58 - More data.
		    ;17FA0 - 19000
    
    mov bx, 0x7F40
    mov ax, 0x9000
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0x1
    mov [edi], ecx

    add edi, 4      ;---------------------
    					; Writing GDTR to the end of GDT...
    mov esi, edi
    sub esi, GDTTableLoc
    dec esi
    mov [edi], si
    mov eax, edi
    add edi, 2
    mov dword [edi], GDTTableLoc
    
    xchg bx, bx
    
    lgdt [eax]
    
    jmp 0x20:ReloadGDT
    
    ReloadGDT:
    
    mov ax, 0x8
    mov ss, ax
    mov ax, 0x18
    mov ds, ax
    mov esp, 0x1000
    mov bp, 0
    
    mov ax, 0x28
    mov gs, ax
    
    call Display.Clear
    
    mov eax, 0x0A440A47			; Printing "GDT" in green
    mov edi, 0
    mov [gs:edi], eax
    add edi, 4
    mov eax, 0x0A54
    mov gs:[edi], eax
    add edi, 4
    
    mov ax, 0x10
    ltr ax
    
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
        
    mov al, 11111100b
    out 0x21, al
    
    mov al, 11111111b
    out 0xA1, al
    
    mov eax, 0x0A490A50			; Printing "PIC" in green
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0A43
    mov gs:[edi], eax
    add edi, 4
    
    push edi
    					; Setting up IDTR...
    mov edi, 0x14300-0x1500-0x64-6-1
    mov word [edi], 0x14300-6-(IDTTableLoc+0x1564)-1
    inc edi
    inc edi
    mov dword [edi], IDTTableLoc+0x1500+0x64
    
    mov ax, 0x0030
    mov es, ax
    
    ;call IOPrint.Init
    call Timer.init
    call PS2.init
    
    mov ebx, 13
    mov eax, Exceptions.GP

    call IDT.ModEntry
    
    mov ebx, 0x20
    mov eax, IRQ.Timer

    call IDT.ModEntry
    
    xchg bx, bx
    
    mov ebx, 0x21
    mov eax, IRQ.PS2
    
    call IDT.ModEntry
    
    mov ebx, 0x30
    mov eax, Syscall_

    call IDT.ModEntry
    
    mov edi, 0x14300-0x1500-0x64-6-1
    lidt [ds:edi]

    pop edi
	 
    mov eax, 0x0A440A49			; Printing "IDT" in green
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0A54
    mov gs:[edi], eax
    add edi, 4

    xchg bx, bx
    
    call ATA.init

    mov eax, 0x0A540A41			; Printing "ATA" in green
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0A41
    mov gs:[edi], eax
    add edi, 4    

    push edi
    mov eax, 1
    mov ebx, 11
    mov edi, 0x13600-0x1564-1
    mov dx, 18h
    mov es, dx

    xchg bx, bx

    call ATA.readSectors		; Reading INFO sector
    pop edi
    
    mov eax, 0x0A4E0A49			; Printing "INFO" in green
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0A4F0A46
    mov gs:[edi], eax
    add edi, 6
    
    push edi
    
    mov edi, 6
    
    mov ax, 0x38
    mov es, ax
    
    mov byte [es:edi], 00000011b	; Setting up System VidBuffer
    inc edi
    inc edi
    mov dword [es:edi], 0xFA0
    mov edi, 0xFA0
    mov esi, 0
    mov ax, 0x50
    mov es, ax
    
    screencopyloop:			; Copying current screen to current VidBuffer
	mov eax, [gs:esi]
	mov [es:edi], eax
	add esi, 4
	add edi, 4
	
	cmp esi, 0x50*25
	jne screencopyloop
    
    add byte [ds:0x19], 2
    mov dword [ds:0x10], 1
    
    sti

    xchg bx, bx
    
    push ds
    
    mov ax, 0x18
    mov ds, ax
    
    mov eax, dword [ds:0x13600-0x1564]	; Grabbing INFO sector signature
    
    cmp eax, 0x40045005			; Checking said signature
    je $
    
    pop ds
    
    push edi
    mov eax, 3
    mov ebx, 12
    mov edi, 0x13000-0x1564-1
    mov dx, 18h
    mov es, dx

    xchg bx, bx

    call ATA.readSectors		; Reading file descriptor sector
    
    
    mov al, [es:0x13600-0x1564+3]	; Getting terminal file number
    
    xor ecx, ecx
    mov cl, al
    
    xchg bx, bx

    mov eax, 0
    mov edx, 0
    
    call StartProgram

StartProgram:
	pusha
	push ecx

	xor esi, esi

	selectfileloop:			; Selecting terminal file
	add esi, 20
	loop selectfileloop
    
    	dec esi
  	add esi, 0x13000-0x1564
    
 	mov al, [es:esi]
 	mov ebx, edx
	add ebx, 10+2+3
 	mov dx, 40h
 	mov es, dx
	xor edi, edi
 	xchg bx, bx
    	
	call ATA.readSectors		; Reading terminal file
 	xor edi, edi

    	mov ax, 0x38
    	mov es, ax
    	
    	add edi, 6
    	
	xor eax, eax
	
	push ds
	mov ax, 0x18
	mov ds, ax
	mov al, [ds:0x19]
	pop ds

	mov cx, 6

	.loop:
		add edi, eax
		loop .loop
	
    	mov byte [es:edi], 00000001b
    	inc edi
    	inc edi
	
	pop ecx
	
   	mov dword [es:edi], ecx
	
	popa
	pusha

	pushfd
    	push dword 0x48
    	push dword eax
    	
   	xchg bx, bx

   	iret

IDT:
    .ModEntry:
	mov edi, IDTTableLoc-1
	shl ebx, 3
        add edi, ebx	
	
        mov [ds:edi], ax
        
        shr eax, 16
        push ax
        
        add edi, 2
        
        mov ax, 0x20 
        mov [ds:edi], ax
        
        add edi, 2
        
        mov al, 0
        mov ah, 10001110b
        mov [ds:edi], ax
        
        add edi, 2
        
        pop ax
        mov [ds:edi], ax
        
        add edi, 2
        
        ret

Exceptions:
    .UD:
        
    
    .DF:
        
    
    .NP:
        
    
    .GP:
        cli      ;ff4
	mov ebp, esp ; Storing stack start
        push eax 
        push ebx 
        push ecx 
        push edx 
        push edi 
        push esi 
        
	xchg esp, ebp
	
        pop eax
        pop ebx
        pop cx
        pop edx
        
        push edx
        push cx
        push ebx
        
	xchg esp, ebp
	sub esp, 4
	
        push word 'GP'
        add esp, 6
	
        call .Panic
        
        pop esi
        pop edi
        pop edx
        pop ecx
        pop ebx
        pop eax
        
        add esp, 4
        
        push eax
        
        add esp, 4
        pop eax
        add eax, 3
        push eax
        sub esp, 4
        
        pop eax
        
        sti
        iret
    
    .Panic:
    	xchg bx, bx
	
	sub esp, 62+2		; Random offset that may break some things
	push eax
	add esp, 62+4
	pop ax

        push ds
	push es
	push ax
        
	mov ax, 0x50
	mov ds, ax
	mov ax, 0x58
	mov es, ax
	
	pop ax
	mov edi, (80*10+14)<<1

	mov [ds:edi+2], ah
	mov [ds:edi], al

	mov ax, cx
	mov edi, 80*15+9
	
	call .HexWrite
	
	mov eax, ebx
	push ax
	shr eax, 8*2
	mov edi, 80*17+40
	
	call .HexWrite

	pop ax

	call .HexWrite

	sub esp, 62+2+4-4-4
	pop eax
	add esp, 62+2-4-4
	
	mov edi, 80*10+28
	
	push ax
	shr eax, 16
	
	call .HexWrite
	pop ax
	call .HexWrite
	
	pop es
	pop ds
	
	xchg bx, bx
	
	mov ecx, 0

	call Display.ReDraw

        xchg bx, bx
        
        cli
	hlt

    .HexWrite:
    	push cx	
	push bx

	mov ch, 0xF+(ErrorBackground<<4)
	push ax
	shr ax, 8
	push ax
	shr al, 4
	mov cl, [es:eax]
	mov [ds:edi*2], cx
	pop ax
	and al, 0xF
	mov cl, [es:eax]
	inc edi
	mov [ds:edi*2], cx
	pop ax
	
	and ax, 0xFF
	push ax
	shr al, 4
	mov cl, [es:eax]
	inc edi
	mov [ds:edi*2], cx
	pop ax
	and al, 0xF
	mov cl, [es:eax]
	inc edi
	mov [ds:edi*2], cx
	
	pop dx
	pop cx
	
	inc edi
	ret

IRQ:
    .Timer:
        cli
        pusha
       	push ds
	
	mov ax, 0x18
	mov ds, ax
	
	mov ecx, ds:[0x10]
	
	pop ds

	call Display.ReDraw

        mov al, 0x20
        out 0x20, al
        
        popa
        sti
        iret
    
    .PS2:
	cli
	pusha
	push ds
	
	mov ax, 0x18
	mov ds, ax
	mov dl, [ds:0x14]
	mov ebx, [ds:0x15]
	
	test dl, 1
	je .PS2.1
	
	mov ax, 0x40
	mov ds, ax

	.PS2.1:
	
	in al, 0x60
	
	mov [ds:ebx], al
	
	mov al, 0x20
        out 0x20, al
        
        popa
        sti
        iret

PS2:
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
        jne $
        
        call .WaitW
        mov al, 0xAB
        out 0x64, al
        
        call .WaitR
        in al, 0x60
        cmp al, 0
        jne $
        
        call .WaitW
        mov al, 0xAE
        out 0x64, al
         
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
            jne $
            
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

Timer:
    .init:
	pusha
	
	mov al, 00110100b
	; 00 11 010 0
	out 0x43, al
	
	mov al, 19886 && 0xffff
	out 0x40, al
	mov al, (19886 >> 4) && 0xffff
	out 0x40, al
	
	popa
	ret

Syscall_:
    push fs
    pusha
    
    mov ax, 0x30
    mov fs, ax
    
    xor eax, eax
    .loop:
        cmp ecx, 0
        je .loopend
        add eax, 6
        dec ecx
        jmp .loop
        
    .loopend:
    cmp byte [fs:eax], 1
    stc
    je .run
    popa
    pop fs
    iret
    
    .run:
        xchg bx, bx
        inc eax
        inc eax
        
        mov ebx, [fs:eax]
        
	cli
        mov [gs:0], ebx
        
        popa
        call [gs:0]
        sti

        clc
        iret

Display:
    .Init:
        pusha
        
        xor edi, edi
        
        ;mov byte [es:edi], 1
        ;inc edi
        ;mov byte [es:edi], 0
        ;inc edi
        
        ;mov dword [es:edi], .ReDraw
        ;add edi, 4
        
        ;mov byte [es:edi], 1
        ;inc edi
        ;mov byte [es:edi], 0
        ;inc edi
        
        ;mov dword [es:edi], .Chr
        ;add edi, 4
        
        ;mov byte [es:edi], 1
        ;inc edi
        ;mov byte [es:edi], 0
        ;inc edi
        
        ;mov dword [es:edi], .Str
        ;add edi, 4
        
        ;mov byte [es:edi], 1
        ;inc edi
        ;mov byte [es:edi], 0
        ;inc edi
        
        ;mov dword [es:edi], .SetXY
        ;add edi, 4
        
        ;mov byte [es:edi], 1
        ;inc edi
        ;mov byte [es:edi], 0
        ;inc edi
        
        ;mov dword [es:edi], .Clear
        ;add edi, 4
        
        popa
        ret
    
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
        mov edi, edx
        
        mov [gs:edi], ax
        
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
            
            mov bl, [ds:0] ;X
            mov bh, [ds:1] ;Y
            
            call .Chr
            
            inc byte [ds:0]
            inc esi
            
            jmp .Str.loop
        
        .Str.end:
            popa
            ret
    
    .Update:
        cmp byte [ds:0], 0x50
        je .Update.incY
        
        ret
        
        .Update.incY:
            inc byte [ds:1]
            sub byte [ds:0], 50h
            jmp .Update
    
    .SetXY:
        cmp bl, 1
        jl .SetXY.set
        je .SetXY.incX
        cmp bl, 2
        je .SetXY.incY
        ret
        
        .SetXY.incY:
            inc byte [ds:1]
            mov byte [ds:0], 0
            jmp .SetXY.end
        
        .SetXY.incX:
            inc byte [ds:0]
            jmp .SetXY.end
        
        .SetXY.set:
            mov [ds:0], al
            mov [ds:1], ah
        
        .SetXY.end:
            call .Update
            ret
    
    .Clear:
        pusha
        xor edi, edi
        mov ecx, 3E8h
        
        .Clear.1:
            mov dword [gs:edi], 0
            add edi, 4
            
            loop .Clear.1
        
        popa
        ret
        
    .ClearB:
        pusha
        xor edi, edi
        cmp ecx, 0
        add edi, 2
        
        .ClearB.loop:
            jz .ClearB.loopend
            add edi, 0xFA2
            dec ecx
            jmp .ClearB.loop
        
        .ClearB.loopend:
        
        mov ecx, 3E8h
        push es
        mov ax, 0x38
        mov es, ax
        
        .ClearB.1:
            mov dword [es:edi], 0
            add edi, 4
            
            loop .ClearB.1
        
        pop es
        popa
        ret
    
    .ReDraw:
        ;xchg bx, bx
        pusha
        xor esi, esi
        xor edi, edi
        add esi, 2
        cmp ecx, 0
	jz .ReDraw.loopend
        
        .ReDraw.loop:
            add esi, 0x6
            loop .ReDraw.loop
        
        .ReDraw.loopend:
        
        mov ecx, 3E8h
        push es
	mov ax, 0x38
	mov es, ax
	
	mov ax, 0x50
	
	mov ebx, [es:esi]
	sub esi, 2
	
	test byte [es:esi], 00000010b		; Checker for system flag
	
	jnz .ReDraw.1
	
	mov ax, 0x40
	
	.ReDraw.1:
	
	mov es, ax
	mov esi, ebx
	
        .ReDraw.loop2:
            mov eax, dword [es:esi]
            mov dword [gs:edi], eax
            add edi, 4
            add esi, 4
            
            loop .ReDraw.loop2
        
        pop es
        popa
        ret

ATAPort equ 0x1F0
ATAPort2 equ 0x170

ATA:
    .init:
	pusha
	
	xor esi, esi
	mov dx, ATAPort+7	;7
	in al, dx
	
	cmp al, 0xff
	stc
	je .init.noDisk
	clc
	
	dec dx			;6
	mov al, 11100000b
	out dx, al
	
	inc dx
	
	.init.DiskCheck:
	
	mov cx, 5
	
	rep in al, dx
	
	dec dx			;6
	dec dx			;5
	
	mov al, 0
	out dx, al
	
	dec dx			;4
	out dx, al
	dec dx			;3
	out dx, al
	dec dx			;2
	out dx, al
	dec dx			;1
	out dx, al
	
	add dx, 6		;7
	mov al, 0xEC
	out dx, al
	
	in al, dx
	
	cmp al, 0
	jz .init.noDisk
	
	.init.1loop:
	    in al, dx

	    test al, 10000000b
	    jnz .init.1loop
	
	in al, dx
	test al, 0
	jnz .init.error ;jnz .init.notATA
	
	push es
	mov ax, 0x8
	mov es, ax
	
	xor edi, edi
	mov ecx, 256
	sub dx, 7	 	;0
	
	rep insw
	
	
	.init.end:
	    shr esi, 1
	    add dx, 6
	    xor eax, eax
	    in al, dx
	    and al, 00001000b
	    shl al, 3
	    add esi, eax
	    
	    push ds
	    mov ax, 18h
	    mov ds, ax
	    mov eax, esi
	    mov [ds:0], al
	    mov [ds:0xF], al
	    pop ds
	    
	    pop es
	    popa
	    ret
	
    	.init.noDisk:
	    jc .init.error
	     
	    mov dx, ATAPort+6
	    in al, dx
	    test al, 4
	    jnz .init.M_to_S
	    
	    or al, 00010000b
	    jmp .init.DiskCheck
	
	.init.M_to_S:
	    cmp esi, 1
	    je .init.1
 	     
	    mov esi, 1
	    mov dx, ATAPort2+6
	    mov al, 10100000b
	    out dx, al
	    dec dx
	    jmp .init.DiskCheck
 	     
	.init.1:
	    mov dx, ATAPort2+6
	    mov al, 10110000b
	    out dx, al
	    dec dx
	    jmp .init.DiskCheck

	.init.error:
	    stc
	    popa
	    ret

	     
    .readSectors:	;eax - # of sectors to read, ebx - starting sector #, edi - buffer
	pusha
	push eax
	push ebx

	push ds
	push ax
	mov ax, 18h
	mov ds, ax
	mov bl, [ds:0xF]
	pop ax
	pop ds
	
	mov dx, ATAPort
	test bl, 2
	jz .readSectors.Port
	
	mov dx, ATAPort2
	
	.readSectors.Port:	;0 
	
	add dx, 6		;6
	and bl, 1
	shr bl, 4
	mov al, bl
	or al, 01000000b
	out dx, al

	inc dx			;7
	mov ecx, 5
	rep in al, dx
	pop ebx
	
	dec dx			;6
	dec dx			;5
	mov al, 0
	out dx, al
	
	dec dx			;4
	out dx, al
	
	dec dx			;3
	mov al, bl
	out dx, al

	dec dx			;2
	pop eax
	push eax
	out dx, al
	
	add dx, 5		;7
	mov al, 20h 
	out dx, al
	
	.readSectors.wait:
	    in al, dx
	    
	    test al, 1
	    jnz .readSectors.error
	
	    test al, 00001000b
	    jnz .readSectors.read
	
	    jmp .readSectors.wait
	
	
	.readSectors.error:
	    pop eax
	    stc
	    jmp .readSectors.end
	
	
	.readSectors.read:
	    pop eax
	    mov ecx, eax
	    xor eax, eax
	    
	    sub dx, 7
	    
	.readSectors.1:
	    add eax, 0x100
	    loop .readSectors.1
	    
	    mov ecx, eax
	    
	    rep insw
	
	.readSectors.end:
	    popa
 	    ret
	


Strings:
    .Panic1:
        db '                                                                                '
        db ',---EXCEPTION----------------------------------------------------------------!!!'
        db '                                                                                '
	db '                                                                                '
        db '                                                                                '
	db '                                                                                '
    
    .Panic3:
        db '                                                                                '
        db '                                                                                '
        db '                                                                                '
        db '                                                                                '
        db '  Exception: #// ErrCode: 0x//\\                                                '
        db '                                                                                '
        db '                                                                                '
        db '  EAX: 0x//\\//\\ EBX: 0x//\\//\\ ECX: 0x//\\//\\ EDX: 0x//\\//\\               '
        db '  ESI: 0x//\\//\\ EDI: 0x//\\//\\                                               '
        db '  CS:  0x//\\ DS:  0x//\\ SS:  0x//\\                                           '
        db '                                                                                '
        db '                                EIP:  0x//\\//\\                                '
        db '                                                                                '
    
    .Panic4:
        db '                                                                                '
        db '   |Enter Xit to return to shell, MeM to dump memory, Cnt to continue in EIP|   '
        db '                                                                                '
        db '                                                                                '
        db '--------------------------------------------------------------------------------'	
        db '                                                                                '
    .HexTable:  db '0123456789ABCDEF'

times 10*512-($-$$) db 0

;GDT:
    ;.null:
    ;    dq 0
    
    
    ;.Kstack:
    ;    dw 0x1000
    ;    dw 0x500
    ;    db 0
        
    ;    db 010010010b
    ;    db 011011000b
    ;    db 0
    
    ;.TSS:
    ;    dw 0x64
    ;    dw 0x1500
    ;    db 0
    
    ;    db 0x89
    ;    db 0x40
    ;    db 0
    
    ;.Kdata:
    ;    dw 0x2ABF
    ;    dw 0x1564
    ;    db 0
        
    ;    db 010010010b
    ;    db 011011001b
    ;    db 0
    
    ;.Kcode:
    ;    dw 0x1400
    ;    dw 0x4000
    ;    db 1
        
    ;    db 010011010b
    ;    db 011011000b
    ;    db 0
    
    ;.Ucode:
    ;    dw 0xFFFF
    ;    dw 0x5400
    ;    db 1
        
    ;    db 010011010b
    ;    db 011011111b
    ;    db 0
    
    ;.Udata:
    ;    dw 0xFFFF
    ;    dw 0x5400
    ;    db 1
        
    ;    db 010010010b
    ;    db 011011111b
    ;    db 0
    
