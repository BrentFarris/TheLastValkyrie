---
title: Commander X16 Hello World (6502 Assembly)
description: How to get a program built and running on the Commander X16 using 6502 Assembly
tags: 6502 assembly acme commander-x16 8-bit-guy
image: https://i.imgur.com/VqNrLYh.png
---

Something that I've always wanted to do, but haven't had enough time to do, is to write a game on an 8-bit computer like the Commodore 64 (C64). I was watching some videos ([Part 1](https://youtu.be/ayh0qebfD2g) & [Part 2](https://youtu.be/sg-6Cjzzg8s)) by David Murry (The 8-Bit guy) where he was talking about this project he started up named the Commander X16. This was very interesting to me because it was an 8-bit computer using a 6502 processor that was inspired by (and seemingly based on) the Commodore 64. I thought, what better way to make a game on an 8-bit computer than one that is being made now days and uses (mostly) all off-the-shelf parts. There are some upgrades such as a VGA video output and 2MB of bank-switching ram for starters (which is nice).

One thing that I had trouble with was finding a 0-to-running Hello World tutorial on the Facebook group or anywhere else. So, I did what any obsessed person would do and stayed up until 3am figuring out how to get a program from scratch, to running on the Commander X16. Below is a video I created showing the process of what you need to do. I'll also write out, in text, below the video on what needs to be done for people who want to translate this page to their native language.

**JMP**
- [Video tutorial](#video-tutorial)
- [Learn 6502 Assembly](#learn-6502-assembly)
- [Commander X16 setup](#commander-x16-setup)
- [Acme 6502 assembler setup](#acme-6502-assembler-setup)
- [Assembling a program (.prg)](#assembling-a-program)
- [Running program on Commander X16](#running-program-on-commander-x16)

## Video tutorial
<iframe width="560" height="315" src="https://www.youtube.com/embed/jgdMaYVfSpo" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

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

## Learn 6502 Assembly
Rather than me re-inventing the tutorial wheel, I will direct you to an incredible website to learn how to program in 6502 Assembly. It took me about 10-20 minutes to go through and learn everything that this page had to offer. Please read through the tutorial if you are not familiar with 6502 Assembly and come back.
- [Amazing Easy 6502 Tutorial](https://skilldrick.github.io/easy6502)
- [Amazing Easy 6502 Simulator](https://skilldrick.github.io/easy6502/simulator.html)

Now that you've gotten your feet wet in 6502 Assembly, I'm going to drop a couple of the reference links that they had on that tutorial site for the instructions, just so I know where to find them easily.
- [Instruction reference 1](http://www.obelisk.me.uk/6502/reference.html)
- [Instruction reference 2](http://www.6502.org/tutorials/6502opcodes.html)

## Commander X16 setup
TBD

## Acme 6502 assembler setup
TBD

## Assembling a program
TBD

## Running program on Commander X16
TBD
