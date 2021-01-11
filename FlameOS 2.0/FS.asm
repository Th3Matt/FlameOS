InfoSector:
	dd 40045005h			   ; Correct FlFS 0.1 signature
	db 01				   ; Bootable file index
	
	times 512-($-InfoSector) db 0

DescriptorSectors:
	Boot.sb:			   ; First file is bootloader, linked with the sectors after boot sector.
		db 00000001b 		   ; Flags. First bit - Present flag, second bit - Segmentation flag - does the size byte point to a segmentaton table file for the file.
		
		db '10Boot.sb'		   ; Filename.
		times 15-($-Boot.sb-1) db 0 ; Padding. 	
		
		db 0			   ; Emergency terminator	
		
		db 00000000b		   ; Owning userID. Last two bits show cpu ring.
		db 10			   ; Size of file in sectors.
		
		db 0
	
	Terminal.ub:
		db 00000001b
		
		db 'Terminal.ub'
		times 15-($-Terminal.ub-1) db 0
		
		db 0
		
		db 11000000b
		
		db 1
		
		db 0


	times 3*512-($-DescriptorSectors) db 0

RawFiles:
	
	%include "FS/Terminal.asm"
