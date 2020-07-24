---
title: BIOS Programming in VirtualBox
description: A quick getting started tutorial on how to write a minimal text/graphics program in VirtualBox without an operating system
tags: bios x86 x64 assembly virtualbox graphics
---

There are two things I want to explain how to do here, **(1)** basic BIOS interrupts and **(2)** setting the color of pixles plotted onto the screen. This is by no means suppose to be the most performant best way to do things, but I'm running this on a 4GHz processor list most anyone else who will be trying this; so I would consider it a great first step.

If you're viewing this guide it means you probably already know what BIOS is (basic input output system) and you've probably already dabbled a bit in assembly. Both of these are technically not required since I'm going through all the steps, but knowing them probably will make the information here stick a bit better.

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

