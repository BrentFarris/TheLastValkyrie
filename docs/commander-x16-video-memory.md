---
title: Commander X16 Video Memory (6502 Assembly)
description: How to write some stuff to video memory to display in the Commander X16
tags: 6502 assembly acme commander-x16 8-bit-guy video-memory
image: https://i.imgur.com/VqNrLYh.png
---

Just dropping this here and will fill out the page later

```asm
*=$0801
    !byte $01,$08,$0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00

LDA #0
STA $9F25 ; Select primary VRAM address
LDA #$20
STA $9F22 ; Set primary address bank to 0, stride to 2

; VPOKE 0,0,1
; VPOKE 0,1,8
; The following is the same as the above

; Set the character to "B"
LDA #0
STA $9F20 ; Set Primary address low byte to 0
LDA #0
STA $9F21 ; Set primary address high byte to 0
LDA #2
STA $9F23 ; Writing $73 to primary address ($00:$0000)

; Set the color to orange
lda #1
sta $9f20	; Next byte over
lda #8
sta $9f23	; Write the color
brk
```
