---
title: BIOS Programming in VirtualBox
description: A quick getting started tutorial on how to write a minimal text/graphics program in VirtualBox without an operating system
tags: bios x86 x64 assembly virtualbox graphics
---

There are two things I want to explain how to do here, **(1)** basic BIOS interrupts and **(2)** setting the color of pixles plotted onto the screen. This is by no means suppose to be the most performant best way to do things, but I'm running this on a 4GHz processor list most anyone else who will be trying this; so I would consider it a great first step.

If you're viewing this guide it means you probably already know what BIOS is (basic input output system) and you've probably already dabbled a bit in assembly. Both of these are technically not required since I'm going through all the steps, but knowing them probably will make the information here stick a bit better.


**JMP**
- [Tools setup](#tool-setup)
- [VM setup](#vm-setup)
- [Project setup](#project-setup)
- [Writing our BIOS enabled code](#writing-our-bios-enabled-code)
  - [Hello, World!](#hello-world)
  - [Quick and dirty debug output](#quick-and-dirty-debug-output)
  - [Hello keyboard input](#hello-keyboard-input)
  - [Hello pixel](#hello-pixel)

## Tools setup
**VirtualBox** - The first thing you are going to need is [VirtualBox](https://www.virtualbox.org/). You could do this stuff right on real hardware, but there are risks with doing such a thing and alos it will take an awfully long time to debug things. Using a virtual machine is helpful for rapid iteration.

**NASM** - We are going to use the [NASM assembler](https://nasm.us/) to assemble our code. You can use this assembler on whatever operating system your on. I'm going to be using Linux on Windows to assemble my code quickly. In Linux just run `sudo apt-get install nasm build-essential` to install all that you need.

## VM setup
![create-the-virtualbox-vm](https://i.imgur.com/5c7X5MT.png)
Open VirtualBox and then select "New" and then select Other/Unknown (32-bit) from the operating system dropdown menu. From there you can give it the most basic setup. I gave mine 64MB of ram and a small elastically sized hard drive. Next, we are going to use a Floppy disk to run our boot code so right click on your VM and select **Settings**. In the settings window select **Storage** then click on the button to add a drive at the bottom. Lastly select the Floppy option (mine is grayed out in the image because I've already added a floppy controller).
![attach-a-floppy-drive-controller](https://i.imgur.com/VXaeMfJ.png)
We have not actually created the floppy disk to load just yet, but we'll get to that in the next step.

## Project setup
Now that we have the VM mostly setup, we can setup the project. Create a folder somewhere on your main drive (I just use the desktop for now) with whatever name you want. Inside of this folder create a raw text file named `main.asm`. Next we will create the floppy drive file, you can use whatever binary file generator you want (or generate the file with C or something), but you need to create a file that contains **1474560** bytes of 0s (the size of a floppy disk). If you are on Linux, you can do this easily by typing the following command:
```sh
head -c 1474560 /dev/zero > bootloader.vfd
```
This will create a file named `bootloader.vfd` which will be full of 0s, ready to have our assembly code written to it.

Now that you have your floppy drive setup, you can attach it to your virtual machine. Something I like to do is to keep a copy of the `bootloader.vfd` file we just generated named `clean-floppy.vfd` so I can just copy it and re-write my code to it for each test. Inside of VirtualBox, back in the **Settings** menu where we attached a floppy controller, you can now click the icon to add a floppy drive. Select the **Add** button and then find your `bootloader.vfd` file and select it to attach.
![attach-the-floppy-disk-to-vm](https://i.imgur.com/LGAim16.png)

With this, the only things you need to know how to do is compile your assembly code using NASM and copy the optcode output to the floppy drive. This shell script of mine should help explain those steps! **WARNING!!!** If you use this script, make sure you have already done the command `cp bootloader.vfd clean-floppy.vfd` so that you have a clean floppy image to work with.
```sh
nasm -f bin -o boot.bin main.asm	# Assemble our main.asm file into it's binary opcodes
rm ./bootloader.vfd			# Remove our old boot loader
cp ./clean-floppy.vfd ./bootloader.vfd	# Copy over our clean boot loader
dd status=noxfer conv=notrunc if=boot.bin of=bootloader.vfd	# Stick our code into the floppy file
```

So basically:
1) `nasm -f bin -o boot.bin main.asm` will assemble our asm file into binary.
2) `rm ./bootloader.vfd` will delete our old image because we are going to write a new one
3) `cp ./clean-floppy.vfd ./bootloader.vfd` will copy our clean (all 0s) floppy image so we can write using a blank slate
4) `dd status=noxfer conv=notrunc if=boot.bin of=bootloader.vfd` Basically just slaps all the bytes in `boot.bin` that was generated from step (1) into the `bootloader.vfd` file. If you were to read the bytes of `bootloader.vfd` after doing this, you'll see that the first 512 bytes will match that of `boot.bin`.

## Writing our BIOS enabled code
The very last thing to do to see anything on the screen is to write our boot loader. Well, not so much of a boot loader because we aren't going to use it to load any other code or anything from our drives. Basically just our boot sector program which will execute some code and run BIOS commands to print stuff and set pixel colors.

### Hello, World!
Now I know you're eager to draw a pixel on the screen, but let's start with the very basic task of getting a "Hello, World!" on the screen. Please be sure to read all the comments in any of the following assembly code files. The comments give you all the context you'll need to understand what is going on. Going through and writing a paragraph for each assembly instruction line seems superfluous and time consuming haha. I like documenting things, but let's let the code do the talking on this one :).
```asm
BITS 16			; Instruct the system this is 16-bit code

; This is the entry point, nothing should happen before this
; other than setting the instruction size
main:
	mov ax, 07C0h	; Setup 4KB stack space after this bootloader
	add ax, 288	; (4096+515) / 16 bytes (aligned) per paragraph
	cli		; Disable interrupts (solvs old DOS bug)
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
.loop:
	jmp .loop	; Infinite loop to hold control of the computer

;------------------------------------------------------------------------------
; Print string subroutine (null terminated string print)
;------------------------------------------------------------------------------
print:
	push ax		; Save the current value of the AX register
	mov ah, 0Eh	; Our first BIOS interrupt:  Teletype output
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
```

You may notice that we used the instruction `int 10h` which could have also been `int 0x10` or `int 16`. This particular interrupt calls into the BIOS for a range of visual functions. The function we used to print to teletype was function `0Eh` which could have also been written as `0x0E` or `14`. When we call a BIOS interrupt, we need to supply a function code in the `ah` register, thus why we used `mov ah, 0Eh` before `int 10h`. To know more about this and other interrupt functions, see this awesome website: [Teletype BIOS interrupt Int 10/AH=0Eh](http://www.ctyme.com/intr/rb-0106.htm).

Armed with this code, you can run the `build.sh` shell script listed above or just run the commands found within it. From this point you can startup your VirtualBox VM and be in awe of your glorious "Hello, World!" program running directly on a machine without the aid of an operating system! You should see something similar to the following:
![hello-world-in-action](https://i.imgur.com/2r2hRIg.png)

### Quick and dirty debug output
As you could imagine, debugging something that runs in the boot sector is a bit difficult. We don't have the ability to hit breakpoints or anything like that, so what can we do? Well, we just learned that we can print things to the screen, so lets write a little helper function to write the value in the `ah` register to the screen in binary format. This will help us debug registers, return values, and flags packed into a byte. A lot of the code below is the same as above, but jump down to the section labeled **Debug printing of bytes** to see the sub-routine added for printing the `ah` register value.
```asm
BITS 16			; Instruct the system this is 16-bit code

; This is the entry point, nothing should happen before this
; other than setting the instruction size
main:
	mov ax, 07C0h	; Setup 4KB stack space after this bootloader
	add ax, 288	; (4096+515) / 16 bytes (aligned) per paragraph
	cli		; Disable interrupts (solvs old DOS bug)
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
.loop:
	jmp .loop	; Infinite loop to hold control of the computer

;------------------------------------------------------------------------------
; Debug printing of bytes
;------------------------------------------------------------------------------
ah_to_str:
	push ax			; Save the state of our AX register
	push cx			; Save the state of our CX register
	mov ch, 80h		; Set bit flag for AND as 10000000
	mov al, ah		; Copy AH to AL so we can change AH
.ah_to_str_loop:
	mov ah, al		; Restore original value of AH
	and ah, ch		; Get the bit value for printing
	test ah, ah		; Check to see if the bit is zero or 1
	je .ah_to_str_zero	; The bit was 0 so jump to print 0
	mov ah, 31h		; The bit was 1 so set AH to ascii 1
	jmp .ah_to_str_print	; Jump to print the character
.ah_to_str_zero:
	mov ah, 30h		; The bit was 0 so set AH to ascii 0
.ah_to_str_print:
	call print_char		; Call our print_char routine below
	SHR ch, 01h		; Shift CH right by 1 (0100000 first time)
	cmp ch, 00h		; Check to see if we shifted all the way
	jne .ah_to_str_loop	; If we haven't finished, return to loop
	pop cx			; Restore the state of our CX register
	pop ax			; Restore the state of our AX register
	ret			; Return to caller location

print_char:
	push ax		; Save the state of our AX register
	push cx		; Save the CX register (due to int 10h clobbering)
	mov al, ah	; AL is used for the character to print
	mov ah, 0Eh	; Teletype BIOS interrupt function
	int 10h		; BIOS interrupt 10h (0x10 or 16 in decimal)
	pop cx		; Restore the state of our CX register
	pop ax		; Restore the state of our AX register
	ret		; Return to caller location

;------------------------------------------------------------------------------
; Print string subroutine (null terminated string print)
;------------------------------------------------------------------------------
print:
	push ax		; Save the current value of the AX register
	mov ah, 0Eh	; Our first BIOS interrupt:  Teletype output
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
```

***NOTE***: Yes we have both duplicate and un-optimized code here that could be improved; but for the sake of example and readability, it is this way. I also just added in the debug print code without modifying the code from the previous "Hello, World!" example. I would highly suggest merging/refactoring the code later because it is wasting our precious 512 bytes we have to work with in our boot sector program.

### Hello keyboard input
What's the point of having a program that just prints things, that is the job of paper! Let us turn this thing into a computer by adding keyboard input shall we? We are going to make use of that handy `print_ah` routine we just wrote so that we can print out the scan code of the key we press on the keyboard. This way we can ensure it is working and also check which key has what scan code. Most of this code is the same, you can jump down to the **Reading keyboard input** section of the code to see how simple it is. Also be sure to check out the `.loop:` section as it has changed for debug printing our keystrokes.
```asm
BITS 16			; Instruct the system this is 16-bit code

; This is the entry point, nothing should happen before this
; other than setting the instruction size
main:
	mov ax, 07C0h	; Setup 4KB stack space after this bootloader
	add ax, 288	; (4096+515) / 16 bytes (aligned) per paragraph
	cli		; Disable interrupts (solvs old DOS bug)
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
s_nl db 0Dh, 0Ah, 00h

;------------------------------------------------------------------------------
; The main loop of our program
;------------------------------------------------------------------------------
run:
	mov si, s_hi		; Set our SI register to hello message pointer
	call print		; Call our print subroutine
.loop:
	call read_keyboard	; Call our keyboard input subroutine
	je .loop		; Return to loop if no key was pressed
	call ah_to_str		; A key was pressed, so let's print it!
	mov si, c_nl		; Move the new line bytes into SI register
	call print		; Print a new line for readability
	jmp .loop		; Infinite loop to hold control of the computer

;------------------------------------------------------------------------------
; Reading keyboard input
;------------------------------------------------------------------------------
read_keyboard:
	mov ah, 00h	; 00h is the get key and clear buffer function in BIOS
	int 16h		; Call the BIOS interrupt for keyboard functions
	test ah, ah	; AH will be 0 if no key was pressed, allow je after
	ret		; Return to caller with ZF and AH set
	
;------------------------------------------------------------------------------
; Debug printing of bytes
;------------------------------------------------------------------------------
ah_to_str:
	push ax			; Save the state of our AX register
	push cx			; Save the state of our CX register
	mov ch, 80h		; Set bit flag for AND as 10000000
	mov al, ah		; Copy AH to AL so we can change AH
.ah_to_str_loop:
	mov ah, al		; Restore original value of AH
	and ah, ch		; Get the bit value for printing
	test ah, ah		; Check to see if the bit is zero or 1
	je .ah_to_str_zero	; The bit was 0 so jump to print 0
	mov ah, 31h		; The bit was 1 so set AH to ascii 1
	jmp .ah_to_str_print	; Jump to print the character
.ah_to_str_zero:
	mov ah, 30h		; The bit was 0 so set AH to ascii 0
.ah_to_str_print:
	call print_char		; Call our print_char routine below
	SHR ch, 01h		; Shift CH right by 1 (0100000 first time)
	cmp ch, 00h		; Check to see if we shifted all the way
	jne .ah_to_str_loop	; If we haven't finished, return to loop
	pop cx			; Restore the state of our CX register
	pop ax			; Restore the state of our AX register
	ret			; Return to caller location

print_char:
	push ax		; Save the state of our AX register
	push cx		; Save the CX register (due to int 10h clobbering)
	mov al, ah	; AL is used for the character to print
	mov ah, 0Eh	; Teletype BIOS interrupt function
	int 10h		; BIOS interrupt 10h (0x10 or 16 in decimal)
	pop cx		; Restore the state of our CX register
	pop ax		; Restore the state of our AX register
	ret		; Return to caller location

;------------------------------------------------------------------------------
; Print string subroutine (null terminated string print)
;------------------------------------------------------------------------------
print:
	push ax		; Save the current value of the AX register
	mov ah, 0Eh	; Our first BIOS interrupt:  Teletype output
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
```

Okay, one thing worth explaining in this code is how we can just call `je .loop` after doing `call read_keyboard` and the program just magically knowing if a key was pressed? Well that is why we do `test ah, ah` before returning from the `read_keyboard` subroutine. The call to BIOS 16h will put the value `0` into `AH` if no key was pressed. So by doing `test ah, ah` we are setting the zero flag ZF to either 0 or 1 based on if anything is in `AH` (1 if `AH` is 0). So then we can do the jump if equal call `je .loop` if `AH` is equal to 0. Also returning from our `read_keyboard` subroutine, the `AH` register will be set to the scancode that was pressed, so we can use our handy debug print to print out the value of `AH`.

### Hello pixel
***; TBD***
```asm
BITS 16			; Instruct the system this is 16-bit code

; This is the entry point, nothing should happen before this
; other than setting the instruction size
main:
	mov ax, 07C0h	; Setup 4KB stack space after this bootloader
	add ax, 288	; (4096+515) / 16 bytes (aligned) per paragraph
	cli		; Disable interrupts (solvs old DOS bug)
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
s_nl db 0Dh, 0Ah, 00h

;------------------------------------------------------------------------------
; The main loop of our program
;------------------------------------------------------------------------------
run:
	mov si, s_hi	; Set our si register to point to the hello message
	call print	; Call our print subroutine to print the message
	
	mov ah, 00h
	mov al, 12h	; 640x480 VGA
	int 10h
	
	mov ah, 0Ch
	mov bh, 00h
	mov al, 0Fh
	mov cx, 0Fh
	mov dx, 0Fh
	int 10h
.loop:
	call read_keyboard
	je .loop
	call ah_to_str
	mov si, c_nl
	call print
	jmp .loop	; Infinite loop to hold control of the computer

;------------------------------------------------------------------------------
; Reading keyboard input
;------------------------------------------------------------------------------
read_keyboard:
	mov ah, 00h
	int 16h
	test ah, ah
	ret
	
;------------------------------------------------------------------------------
; Debug printing of bytes
;------------------------------------------------------------------------------
print_char:
	push ax
	push cx
	mov al, ah
	mov ah, 0Eh
	mov bl, 01h
	int 10h
	pop cx
	pop ax
	ret

ah_to_str:
	push ax
	push cx
	mov ch, 80h
	mov al, ah
.ah_to_str_loop:
	mov ah, al
	and ah, ch
	test ah, ah
	je .ah_to_str_zero
	mov ah, 31h
	jmp .ah_to_str_print
.ah_to_str_zero:
	mov ah, 30h
.ah_to_str_print:
	call print_char
	SHR ch, 01h
	cmp ch, 00h
	jne .ah_to_str_loop
	pop cx
	pop ax
	ret

;------------------------------------------------------------------------------
; Print string subroutine (null terminated string print)
;------------------------------------------------------------------------------
print:
	push ax		; Save the current value of the AX register
	mov ah, 0Eh	; Our first BIOS interrupt:  Teletype output
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
```
