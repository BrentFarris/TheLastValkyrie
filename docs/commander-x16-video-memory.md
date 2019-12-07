---
title: Commander X16 Video Memory (6502 Assembly)
description: How to write some stuff to video memory to display in the Commander X16
tags: 6502 assembly acme commander-x16 8-bit-guy video-memory
image: https://i.imgur.com/VqNrLYh.png
---

First of all, if you don't know how to make a 6502 Assembled project from scratch and run it on the Commander X16, check out the [Commander X16 hello world 6502 Assembly](commander-x16-hello-world-6502-assembly.md) page I made on how to do that.

**JMP**
- [Tutorial video](#tutorial-video)
- [The BASIC idea](#the-basic-idea)
- [VPOKE to 6502 Assembly](#vpoke-to-6502-assembly)
- [Drawing 5 green hearts](#drawing-5-green-hearts)

## Tutorial video
<iframe width="560" height="315" src="https://www.youtube.com/embed/ZXn-lpf9f_k" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[Click this link to learn about how I wrote a 6502 Assembler](https://thelastvalkyrie.net/writing-6502-assembler.html).

## The BASIC idea
Now that I have a program running within the emulator, I was interested in how I can do something small with the video chip. What I was finally able to do was set a character on the screen and pick it's color. My research materials were the [VERA documentation](https://github.com/commanderx16/x16-docs/blob/master/VERA%20Programmer's%20Reference.md#external-address-space) and a [helpful document](https://docs.google.com/document/d/1pFlevjsf_PRcOb0QLJp9IGihgYsVtUIxEW5ZZqtu0z0/) created by another member of the Facebook group.

I was watching [a video](https://www.facebook.com/adric22/videos/10157689827480962/) posted by David Murry in the Facebook group that showed him using the command `VPOKE` with 3 arguments. So I got it in my head that if I could figure out how those 3 arguments mapped to 6502 Assembly (what addresses they were) I would be able to do the same thing. Needless to say, after looking at the VERA documentation on the addresses for the chip, I was able to test enough to get the same thing working.

## VPOKE to 6502 Assembly
So first we should describe the anatomy of VPOKE. This command takes 3 arguments **bank**, **address**, and **value** respectively. These directly translate over to assembly instructions as you can see in the following table.

| VPOKE | Memory Address |           Description         |
| :---: | :------------: | :---------------------------- |
| arg 1 |      $9F22     | Bank / stride                 |
| arg 2 |      $9f20     | Low address for video memory  |
| arg 3 |      $9f23     | Data address for video memory |

Check out the comments in the following code, you might also want to look back and forth between the code and the above table to get the full picture.
```asm
*=$0801
!byte $01,$08,$0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00

LDA #0
STA $9F25	; Select primary VRAM address
LDA #$20	; VPOKE 1st argument (The 0x00 in this is the 0 bank)
STA $9F22	; Set primary address bank to 0, stride to 2

; VPOKE 0,0,2
; VPOKE 0,1,8
; The following is the same as the 2 above VPOKE statements

LDA #0		; VPOKE 2nd argument
STA $9F20	; Set Primary address low byte to 0
LDA #0		; Not using the high byte, just want to stay on <0,0>
STA $9F21	; Set primary address high byte to 0
LDA #2		; VPOKE 3rd argument (set the character to "B")
STA $9F23	; Writing $73 to primary address ($00:$0000)

; Set the color to orange
LDA #1		; VPOKE 2nd argument (next byte over)
STA $9f20	; Next byte over
LDA #8		; VPOKE 3rd argument (orange color code)
STA $9f23	; Write the color
BRK
```

## Drawing 5 green hearts
Now that we have a basic understanding of how we can draw something to the screen. Let's try and draw 5 green hearts to the screen. The 2 things to know is that a heart character in PETSCII is $53 (see bottom left corner of [PETSCII square here](https://en.wikipedia.org/wiki/PETSCII)), and the second is that the code for green is `#5`.
```asm
*=$0801
!byte $01,$08,$0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00

LDA #0		
STA $9F25	; Select primary VRAM address
LDA #$20	; VPOKE 1st argument (The 0x00 in this is the 0 bank)
STA $9F22	; Set primary address bank to 0, stride to 2
LDA #0
STA $9F21	; Set primary address high byte to 0

LDX #0		; Loop counter
LDY #0		; Address offset
next_heart:
	TYA
	STA $9F20	; Set Primary address low byte to 0
    
	LDA #$53	; <3
	STA $9F23	; Data line
	INY
	TYA		; Next byte over is color
	STA $9f20
	LDA #5		; Green
	STA $9f23	; Write the color
	INX
	INY
	CPX #5
	BNE next_heart
BRK
```
Looking at the code above, you may notice that we are incrementing the byte value we put into address `$9F20` 2 times each iteration of the loop. This is because the first byte is the character we want to write, and the next byte over is the color we want to pick. So you can think of it as the following:

| $9F20 Value |               Usage <x,y>               |
| :---------: | :-------------------------------------- |
|      0      | The character for top left corner <0,0> |
|      1      | Color for previous <0,0>                |
|      2      | The character for next space <1,0>      |
|      3      | Color for previous <1,0>                |
|      4      | The character for next space <2,0>      |
|      5      | Color for previous <2,0>                |
|     ...     | etc.                                    |
