
Boot.bin: Bootloader PrintFunc.asm A20Func.asm DiskOp.asm Drivers.asm MakerKernel
	nasm -fbin Bootloader -o BL.bin
	nasm -fbin MakerKernel -o MK.bin
	dd if=BL.bin of=Boot.bin bs=512 conv=notrunc
	dd if=MK.bin of=Boot.bin bs=512 seek=1 conv=notrunc

Clean: 
	rm Boot.bin
	rm OS/Boot.bin

BDP: BootDrivePrinter PrintFunc.asm
	nasm -fbin BootDrivePrinter -o Boot.bin

RunFloppy: OS.img
	qemu-system-x86_64 -drive file=OS.img,if=floppy,format=raw
	
RunFloppyADV: OS.img
	qemu-system-x86_64 -drive file=OS.img,if=floppy,format=raw -monitor stdio

RunCD: OS.iso
	qemu-system-x86_64 -drive file=OS.iso,media=cdrom,format=raw

Run: Boot.bin
	qemu-system-x86_64 Boot.bin

Build: Boot.bin
	truncate Boot.bin -s 1200k
	cp Boot.bin OS.img
	cp Boot.bin OS
	mkisofs -o OS.iso -b Boot.bin OS


FS.bin: Bootloader
	nasm -fbin Bootloader -o "Builds/BL.bin"
	nasm -fbin FS -o "Builds/FS1.bin"
	dd if="Builds/BL.bin" of="Builds/FS.bin" bs=512 conv=notrunc
	dd if="Builds/FS1.bin" of="Builds/FS.bin" bs=512 seek=1 conv=notrunc
	

BuildFS: FS.bin
	truncate "Builds/FS.bin" -s 1200k
	cp "Builds/FS.bin" "Builds/OS.img"
	cp "Builds/FS.bin" OS

