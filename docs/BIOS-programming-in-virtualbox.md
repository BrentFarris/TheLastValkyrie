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
Now I know you're eager to draw a pixel on the screen, but let's start with the very basic task of getting a "Hello, World!" on the screen.
```asm
BITS 16			; Instruct the system this is 16-bit code

; This is the entry point, nothing should happen before this
; other than setting the instruction size
main:
	mov ax, 0x07C0	; Setup 4KB stack space after this bootloader
	add ax, 288	; (4096+515) / 16 bytes (aligned) per paragraph
	cli		; Disable interrupts (solvs old DOS bug)
	mov ss, ax	; Assign current stack segment
	mov sp, 4096	; Setup our stack pointer
	sti		; Enable interrupts (solvs old DOS bug)
	mov ax, 0x07C0	; 0x07C0 is where our program is located
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
	cmp al, 0x00	; Check if we are at end of string (0 = end of string)
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

*; TODO:  Explain each pice of the above assembly behond what is in the comments*

[Teletype BIOS interrupt Int 10/AH=0Eh](http://www.ctyme.com/intr/rb-0106.htm)

Armed with this code, you can run the `build.sh` shell script listed above or just run the commands found within it. From this point you can startup your VirtualBox VM and be in awe of your glorious "Hello, World!" program running directly on a machine without the aid of an operating system! You should see something similar to the following:
![hello-world-in-action](https://i.imgur.com/2r2hRIg.png)
