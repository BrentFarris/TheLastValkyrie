---
title: Commander X16 Video Memory (6502 Assembly)
description: How to write some stuff to video memory to display in the Commander X16
tags: 6502 assembly acme commander-x16 8-bit-guy video-memory
image: https://i.imgur.com/VqNrLYh.png
---

First of all, if you don't know how to make a 6502 Assembled project from scratch and run it on the Commander X16, check out the [Commander X16 hello world 6502 Assembly](commander-x16-hello-world-6502-assembly.md) page I made on how to do that.

**JMP**
- [The BASIC idea](#the-basic-idea)
- [VPOKE to 6502 Assembly](#vpoke-to-6502-assembly)

## The BASIC idea
Now that I have a program running within the emulator, I was interested in how I can do something small with the video chip. What I was finally able to do was set a character on the screen and pick it's color. My research materials were the [VERA documentation](https://github.com/commanderx16/x16-docs/blob/master/VERA%20Programmer's%20Reference.md#external-address-space) and a [helpful document](https://docs.google.com/document/d/1pFlevjsf_PRcOb0QLJp9IGihgYsVtUIxEW5ZZqtu0z0/) created by another member of the Facebook group.

I was watching [a video](https://www.facebook.com/adric22/videos/10157689827480962/) posted by David Murry in the Facebook group that showed him using the command `VPOKE` with 3 arguments. So I got it in my head that if I could figure out how those 3 arguments mapped to 6502 Assembly (what addresses they were) I would be able to do the same thing. Needless to say, after looking at the VERA documentation on the addresses for the chip, I was able to test enough to get the same thing working.

## VPOKE to 6502 Assembly
So first we should describe the anatomy of VPOKE. This command takes 3 arguments **bank**, **address**, and **value** respectively. These directly translate over to assembly instructions as you can see in the following table.

| VPOKE | Memory Address |
| :---: | :------------: |
| arg 1 |      $9F22     |
| arg 2 |      $9f20     |
| arg 3 |      $9f23     |

```asm
*=$0801
    !byte $01,$08,$0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00

LDA #0
STA $9F25 ; Select primary VRAM address
LDA #$20
STA $9F22 ; Set primary address bank to 0, stride to 2

; The following is the same as VPOKE 0,0,1

; Set the character to "B"
LDA #0
STA $9F20 ; Set Primary address low byte to 0
LDA #0
STA $9F21 ; Set primary address high byte to 0
LDA #2
STA $9F23 ; Writing $73 to primary address ($00:$0000)

; The following is the same as VPOKE 0,1,8

; Set the color to orange
lda #1
sta $9f20	; Next byte over
lda #8
sta $9f23	; Write the color
brk
```
TBD
