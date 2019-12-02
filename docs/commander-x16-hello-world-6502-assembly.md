---
title: Commander X16 Hello World (6502 Assembly)
description: How to get a program built and running on the Commander X16 using 6502 Assembly
tags: 6502 assembly acme commander-x16 8-bit-guy
image: https://i.imgur.com/VqNrLYh.png
---

I am spoiled by visual studio (where I develop x86 and x64 assembly code) for windows or use the ARM tools on Linux. I searched through the Facebook group [here](https://www.facebook.com/groups/CommanderX16) for a very simple 0-to-running hello world tutorial for 6502 Assembly but only mainly got bits and pieces. So after being up until 3am I finally got a program running in the emulator using 6502 assembly (all of 3 lines but it is a start). Now that I figured out how to go from 0 to running a program in the emulator I thought I would share it for all those I've seen asking about getting a program up and working in 6502 assembly.

**Note 1:** While C is my favorite programming language, and I have a lot of experience in it, all the fun in this for me is to write Assembly code by hand on such a limited CPU.

**Note 2:**  While I show everything you need to write a 6502 assembly program and get it running in the Commander X16 emulator, I have a few questions in this video for anyone who can give me a solid answer :)

<iframe width="560" height="315" src="https://www.youtube.com/embed/jgdMaYVfSpo" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Video Description
I was looking around the 8-bit guy's Commander X16 Facebook project page to find a getting started tutorial on how to write assembly for the machine but could not find anything that was a bare-bones, simple tutorial. So after a lot of reverse engineering and reading of many different documents for both the Commodore 64 (C64) and user made programs on the Commander X16 I finally got something working. So in this video I wanted to show the very basics of how to get started in both 6502 Assembly programming as well as how to get a program running in the Commander X16 emulator. This might not be 100% correct or accurate, but as far as I can tell, it is doing exactly what I want it to do. This tutorial will go over how to go from 0 to having a 6502 assembled program that you wrote running on the Commander X16 (well at least the emulator).

------- Video Links -------
- Easy 6502 Tutorials ► [https://skilldrick.github.io/easy6502](https://skilldrick.github.io/easy6502)
- Commander X16 Docs/Emulator ► [https://github.com/commanderx16](https://github.com/commanderx16)
- Acme 6502 Assembler ► [https://sourceforge.net/projects/acme-crossass/files/win32/](https://sourceforge.net/projects/acme-crossass/files/win32/)
- Commander X16 Facebook  ► [https://www.facebook.com/groups/CommanderX16](https://www.facebook.com/groups/CommanderX16)
- Code in video ► [https://gist.github.com/BrentFarris/b143b1e2442385721df65df084561903](https://gist.github.com/BrentFarris/b143b1e2442385721df65df084561903)

```asm
*=$0801
	!byte $01,$08,$0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00

lda #$09
sta $08f0
brk
```
