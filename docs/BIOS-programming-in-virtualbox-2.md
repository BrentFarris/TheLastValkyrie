---
title: BIOS Programming in VirtualBox Part 2
description: Part 2 to my previous BIOS programming tutorial, we'll be looking at getting out of the boot sector
tags: bios x86 x64 assembly virtualbox memory floppy
---

So in the [last document about BIOS programming](BIOS-programming-in-virtualbox.md) we looked at how to get setup to writing a boot loader that will run from a floppy drive on VirtualBox using BIOS. In this document we'll take a look at how we can jailbreak out of the boot sector and make it so we are not stuck with 512 bytes memory for our code. The way we'll do this is by loading up some more data from the floppy drive using BIOS interrupts and then jumping off into our newly loaded code. This will give us much more space for our programs.

**JMP**
- [Prerequisite](#prerequisite)
- [Loading data into memory](#loading-data-into-memory)

## Prerequisite
In order to follow along with this document, you probably will want to check out the [previous document](BIOS-programming-in-virtualbox.md) to get the starter code and your VM setup in VirtualBox.

## Loading data into memory
Now that we have a working program, it's time for us to jail-break out of our 512 bytes of memory by jumping to another part of memory which will have some code we can execute. There are 2 things we need to do in order to do this; (1) write some code that we can jump to at a specific address, and (2) jump to the new address from the boot loader.

We'll begin by writing the code we wish to inject into the floppy drive. We could create it's own assembly file and in turn it's own object file which we can then insert into our floppy image; but for simplicity we'll stick to a single assembly file for now.
```nasm
BITS 16			; Instruct the system this is 16-bit code

; This is the entry point, nothing should happen before this
; other than setting the instruction size
main:
	mov ax, 07C0h	; Setup 4KB stack space after this bootloader
	add ax, 288	; (4096+515) / 16 bytes (aligned) per paragraph
	cli		; Disable interrupts (solves old DOS bug)
	mov ss, ax	; Assign current stack segment
	mov sp, 4096	; Setup our stack pointer
	sti		; Enable interrupts (solvs old DOS bug)
	mov ax, 07C0h	; 07C0h is where our program is located
	mov ds, ax	; Set data segment to the load point of our program
	call run	; Start the main loop

;------------------------------------------------------------------------------
; Constants
;------------------------------------------------------------------------------
s_hi db "Hello, World!", 0Dh, 0Ah, "- Brent", 0Dh, 0Ah, 00h

;------------------------------------------------------------------------------
; The main loop of our program
;------------------------------------------------------------------------------
run:
	mov si, s_hi	; Set our si register to point to the hello message
	call print	; Call our print subroutine to print the message

	mov ah, 02h	; Read sectors
	mov al, 01h	; We want to read 1 sector
	mov ch, 00h	; From cylinder number 0
	mov cl, 02h	; Sector # (Boot 1 [index starts at 1 not 0])
	mov dh, 00h	; Head number 0
	xor bx, bx
	mov es, bx	; es should be 0
	mov bx, 7E00h	; To address; program boot address + 512
	int 13h		; Read floppy drive interrupt
	push 7E00h	; Don't let the assembler treat this as local offset
	ret		; Jump to the pushed address

;------------------------------------------------------------------------------
; Print string subroutine (null terminated string print)
;------------------------------------------------------------------------------
print:
	push ax		; Save the current value of the AX register
	mov ah, 0Eh	; Our first BIOS interrupt:  Teletype output
	mov bl, 0Fh	; Don't worry about me until the end of this guide
.repeat:
	lodsb		; Load next character into AL register
	cmp al, 00h	; Check if we are at end of string (0 = end of string)
	je .done	; If AL is 0 then jump to done label
	int 10h		; BIOS interrupt 10h (0x10 or 16 in decimal)
	jmp .repeat	; Continue to next character in the string
.done:
	pop ax		; Restore the value to the AX register
	ret		; Return to caller location

;------------------------------------------------------------------------------
; Boot loaders are 512 bytes in size so pad the remaining bytes with 0
;------------------------------------------------------------------------------
times 510-($-$$) db 0	; Pad (510 - current position) bytes of 0

dw 0xAA55		; Boot sector code trailer

;------------------------------------------------------------------------------
; Code which is loaded to 7E00h (512 bytes after 7C00h- our program boot addr)
;------------------------------------------------------------------------------
wild_zone:
	mov si, freedom		; Set our si register to point to the hello message
	call print		; Call our print subroutine to print the message
.loop:
	jmp .loop		; Infinite loop to hold control of the computer

;------------------------------------------------------------------------------
; Constants
;------------------------------------------------------------------------------
freedom db "You're free!", 00h
```
