---
title: Writing a 6502 Assembler
description: Going through and explaining the 6502 assembler that I wrote
tags: 6502 assembly assembler writing-6502 writing-assembler
image: https://i.imgur.com/Ja6zIYk.png
---

So I wrote a 6502 Assembler which uses the same syntax you would find in most online tutorials like [this one](https://skilldrick.github.io/easy6502/index.html). I found the syntax simple and straight forward to what I needed and the documentation for many other assemblers fairly shotty and with their own unique symbols for things. Like not being able to do `define thing $9F` in other assemblers is fairly frustrating. For example, if you were to just copy the snake game directly from the above tutorial link, and paste it into a file, then run it through my assembler, it will assemble it to the same exact hexcode of the site. There are some additions that are required (such as program address offset) but we'll cover that stuff further down this page.

**JMP**
- [Some background info and goals](#some-background-info-and-goals)
- [Trying it out](#trying-it-out)
- [Setting the program offset](#setting-the-program-offset)
- [Special instruction DCB](#special-instruction-dcb)
- [Special symbols (#< and #>)](#special-symbols--and-)
- [Instruction table](#instruction-table)

## Some background info and goals
I wanted to make sure this assembler would assemble code that will work on any machine which runs 6502 machine code. So before writing out this page I made sure that it worked by writing a program that I could assemble and run on the Commodore 64 VICE emulator. For this I just quickly grabbed some code [from the internet](http://1amstudios.com/2014/12/07/c64-smooth-scrolling/) and assembled it using my assembler. From there I dropped the generated `.prg` file onto VICE to run it and it worked out great. Below is an image of VICE running the program and the source code I used.
```asm
*=$0800
DCB $01 $08 $0b $08 $01 $00 $9e $32 $30 $36 $31 $00 $00 $00

LDX #0		; X = 0
loop:
TXA  	        ; copy X to A
STA $0400,X	; put A at $0400+X
STA $d800,X	; put A as a color at $d800+x. Color RAM only considers the lower 4 bits, 
		; so even though A will be > 15, this will wrap nicely around the 16 available colors
INX		; X=X+1
CPX #27		; have we written enough chars?
BNE loop
RTS		; all done
```
![working program in commodore 64 from assembly](https://i.imgur.com/Ja6zIYk.png)

## Trying it out
I know that this assembler is not really anything that anyone want's to try out or mess with, but if you have any interest in it feel free to check it out. The C# project is [open source on GitHub](https://github.com/BrentFarris/Brents6502). I'll probably add more to the assembler as I need it, but the main goal was to (1) learn all about 6502 assembly and (2) create an Assembler that is bare bones and works with the syntax I know so far. Yes, yes, I know there are a ton of assemblers out there that I can just download and use (and I have) but that takes all the fun out of things; what can I say, I'm curious.

## Setting the program offset
Setting the program offset is fairly standard across the compilers I've looked at so I followed the same syntax. Below is an example of how you can set the program starting address in hexidecimal. Note that decimal is not supported because I don't see the necessity for it at the moment. Most computers like the Commodore 64 or [Commander X16](commander-x16-hello-world-6502-assembly.md) will tell you the program starting address in hex anyway.
```asm
*=$6502
```
You can use this to change the relative address of the branch/jump addresses on the fly, this is useful if you use a feature of the system to setup something but your program code is starting at a different location (see below). Basically, the short of this is that when the assembler inputs the address for any branch or jump logic, it uses this relative address to know what value to replace labels with. Normally, when you type something like `JMP my_label` the assembler will replace it with `JMP $0608` then use that as the absolute address. If we used this exact example, let's imagine our address was set to `*=$0600`, if we then changed it to `*=0800` then the `JMP my_label` will be turned into `JMP $0808`.
```asm
*=$06FF ; Set relative address
; Do some instructions that use the above relative address
*=$0600 ; Set back to where program code is
```

## Special instruction DCB
Something you don't see in the linked tutorial is an instruction named `DCB`. This is because it is not an instruction on the CPU, it is more of an instruction for the assembler. It tells the assembler to put bytes directly within your program code. So if you had the following assembly code:
```asm
DEX
player_data:
DCB $99 $84 $F3 $1F
```
Then your program will have the following code (see the [instruction table](#instruction-table) for the instruction [DEX](#DEX) to see where the `CA` comes from):
```asm
CA 99 84 F3 1F
```

## Special symbols (#< and #>)
While developing in 6502 assembly you are going to want to get the address high byte and low byte for labels. This will help you to store jump addresses within the zero page of memory so you can essentially pass a label as an argument to a routine. Though this is primarily useful for labels, you could also just use the standard address syntax here as well. Below is an example of how it is used and what it will produce when used.
```asm
LDA #>try_something
STA $00
LDA #<try_something
STA $01
NOP
try_something:  ; For learning, assume the address for this label is $18F3
TAX
;...
```
The following is what the assembler will turn your code into:
```asm
LDA #$18
STA $00
LDA #$F3
STA $01
NOP
try_something:  ; For learning, assume the address for this label is $18F3
TAX
;...
```

## Instruction table
Below is a table of all the instructions for the assembler, note that there is a `DCB` instruction, this is because the following is completely auto-generated from the assembler source code using reflection. Below is a table to describe how the big table works.

|   Column    | Description |
| :---------: | :---------- |
|  Mnemonic   | The instruction name |
|  Argument   | The type of argument provided to the instruction |
|   OpCode    | The hex code that is written to identify this instruction |
|    Flags    | The flags that are affected by the invocation of this instruction  |
|    Clock    | The number of clock cycles this instruction takes to execute |
|  SkipClock  | Really only used on branches for if the branch is skipped |
| BoundsClock | The additional clock cycles required if this instruction passes a page boundary during execution |

[ADC](#ADC) / [AND](#AND) / [ASL](#ASL) / [BCC](#BCC) / [BCS](#BCS) / [BEQ](#BEQ) / [BIT](#BIT) / [BMI](#BMI) / [BNE](#BNE) / [BPL](#BPL) / [BRK](#BRK) / [BVC](#BVC) / [BVS](#BVS) / [CLC](#CLC) / [CLD](#CLD) / [CLI](#CLI) / [CLV](#CLV) / [CMP](#CMP) / [CPX](#CPX) / [CPY](#CPY) / [DCB](#DCB) / [DEC](#DEC) / [DEX](#DEX) / [DEY](#DEY) / [EOR](#EOR) / [INC](#INC) / [INX](#INX) / [INY](#INY) / [JMP](#JMP) / [JSR](#JSR) / [LDA](#LDA) / [LDX](#LDX) / [LDY](#LDY) / [LSR](#LSR) / [NOP](#NOP) / [ORA](#ORA) / [PHA](#PHA) / [PHP](#PHP) / [PLA](#PLA) / [PLP](#PLP) / [ROL](#ROL) / [ROR](#ROR) / [RTI](#RTI) / [RTS](#RTS) / [SBC](#SBC) / [SEC](#SEC) / [SED](#SED) / [SEI](#SEI) / [STA](#STA) / [STX](#STX) / [STY](#STY) / [TAX](#TAX) / [TAY](#TAY) / [TSX](#TSX) / [TXA](#TXA) / [TXS](#TXS) / [TYA](#TYA)

| Mnemonic | Argument | OpCode | Flags | Clock | SkipClock | BoundsClock |
| :------: | :------: | :----: | :---: | :---: | :-------: | :---------: |
| <a name="ADC">ADC</a> | #09 or #$F9 | 0x69 | N O Z C | 2 | 0 | 0 |
| <a name="ADC">ADC</a> | $F9 | 0x65 | N O Z C | 3 | 0 | 0 |
| <a name="ADC">ADC</a> | $F9,X | 0x75 | N O Z C | 4 | 0 | 0 |
| <a name="ADC">ADC</a> | $0200 | 0x6D | N O Z C | 4 | 0 | 0 |
| <a name="ADC">ADC</a> | $0200,X | 0x7D | N O Z C | 4 | 0 | 1 |
| <a name="ADC">ADC</a> | $0200,Y | 0x79 | N O Z C | 4 | 0 | 1 |
| <a name="ADC">ADC</a> | ($09),X | 0x61 | N O Z C | 6 | 0 | 0 |
| <a name="ADC">ADC</a> | ($09),Y | 0x71 | N O Z C | 5 | 0 | 1 |
| <a name="AND">AND</a> | #09 or #$F9 | 0x29 | N Z | 2 | 0 | 0 |
| <a name="AND">AND</a> | $F9 | 0x25 | N Z | 3 | 0 | 0 |
| <a name="AND">AND</a> | $F9,X | 0x35 | N Z | 4 | 0 | 0 |
| <a name="AND">AND</a> | $0200 | 0x2D | N Z | 4 | 0 | 0 |
| <a name="AND">AND</a> | $0200,X | 0x3D | N Z | 4 | 0 | 1 |
| <a name="AND">AND</a> | $0200,Y | 0x39 | N Z | 4 | 0 | 1 |
| <a name="AND">AND</a> | ($09),X | 0x21 | N Z | 6 | 0 | 0 |
| <a name="AND">AND</a> | ($09),Y | 0x31 | N Z | 5 | 0 | 1 |
| <a name="ASL">ASL</a> |   | 0x0A | N Z C | 2 | 0 | 0 |
| <a name="ASL">ASL</a> | A | 0x0A | N Z C | 2 | 0 | 0 |
| <a name="ASL">ASL</a> | $F9 | 0x06 | N Z C | 5 | 0 | 0 |
| <a name="ASL">ASL</a> | $F9,X | 0x16 | N Z C | 6 | 0 | 0 |
| <a name="ASL">ASL</a> | $0200 | 0x0E | N Z C | 6 | 0 | 0 |
| <a name="ASL">ASL</a> | $0200,X | 0x1E | N Z C | 7 | 0 | 0 |
| <a name="BCC">BCC</a> | $0200 | 0x90 |  | 1 | 1 | 1 |
| <a name="BCS">BCS</a> | $0200 | 0xB0 |  | 1 | 1 | 1 |
| <a name="BEQ">BEQ</a> | $0200 | 0xF0 |  | 1 | 1 | 1 |
| <a name="BIT">BIT</a> | $F9 | 0x24 | N O Z | 3 | 0 | 0 |
| <a name="BIT">BIT</a> | $0200 | 0x2C | N O Z | 3 | 0 | 0 |
| <a name="BMI">BMI</a> | $0200 | 0x30 |  | 1 | 1 | 1 |
| <a name="BNE">BNE</a> | $0200 | 0xD0 |  | 1 | 1 | 1 |
| <a name="BPL">BPL</a> | $0200 | 0x10 |  | 1 | 1 | 1 |
| <a name="BRK">BRK</a> |   | 0x00 |  | 7 | 0 | 0 |
| <a name="BVC">BVC</a> | $0200 | 0x50 |  | 1 | 1 | 1 |
| <a name="BVS">BVS</a> | $0200 | 0x70 |  | 1 | 1 | 1 |
| <a name="CLC">CLC</a> |   | 0x18 | C | 2 | 0 | 0 |
| <a name="CLD">CLD</a> |   | 0xD8 | D | 2 | 0 | 0 |
| <a name="CLI">CLI</a> |   | 0x58 | I | 2 | 0 | 0 |
| <a name="CLV">CLV</a> |   | 0xB8 | O | 2 | 0 | 0 |
| <a name="CMP">CMP</a> | #09 or #$F9 | 0xC9 |  | 2 | 0 | 0 |
| <a name="CMP">CMP</a> | $F9 | 0xC5 |  | 3 | 0 | 0 |
| <a name="CMP">CMP</a> | $F9,X | 0xD5 |  | 4 | 0 | 0 |
| <a name="CMP">CMP</a> | $0200 | 0xCD |  | 4 | 0 | 0 |
| <a name="CMP">CMP</a> | $0200,X | 0xDD |  | 4 | 0 | 1 |
| <a name="CMP">CMP</a> | $0200,Y | 0xD9 |  | 4 | 0 | 1 |
| <a name="CMP">CMP</a> | ($09),X | 0xC1 |  | 6 | 0 | 0 |
| <a name="CMP">CMP</a> | ($09),Y | 0xD1 |  | 5 | 0 | 1 |
| <a name="CPX">CPX</a> | #09 or #$F9 | 0xE0 | N Z C | 2 | 0 | 0 |
| <a name="CPX">CPX</a> | $F9 | 0xE4 | N Z C | 3 | 0 | 0 |
| <a name="CPX">CPX</a> | $0200 | 0xEC | N Z C | 4 | 0 | 0 |
| <a name="CPY">CPY</a> | #09 or #$F9 | 0xC0 | N Z C | 2 | 0 | 0 |
| <a name="CPY">CPY</a> | $F9 | 0xC4 | N Z C | 3 | 0 | 0 |
| <a name="CPY">CPY</a> | $0200 | 0xCC | N Z C | 4 | 0 | 0 |
| <a name="DCB">DCB</a> | $F9 | 0xFF |  | 0 | 0 | 0 |
| <a name="DEC">DEC</a> | $F9 | 0xC6 | N Z | 5 | 0 | 0 |
| <a name="DEC">DEC</a> | $F9,X | 0xD6 | N Z | 6 | 0 | 0 |
| <a name="DEC">DEC</a> | $0200 | 0xCE | N Z | 6 | 0 | 0 |
| <a name="DEC">DEC</a> | $0200,X | 0xDE | N Z | 7 | 0 | 0 |
| <a name="DEX">DEX</a> |   | 0xCA |  | 2 | 0 | 0 |
| <a name="DEY">DEY</a> |   | 0x88 |  | 2 | 0 | 0 |
| <a name="EOR">EOR</a> | #09 or #$F9 | 0x49 | N Z | 2 | 0 | 0 |
| <a name="EOR">EOR</a> | $F9 | 0x45 | N Z | 3 | 0 | 0 |
| <a name="EOR">EOR</a> | $F9,X | 0x55 | N Z | 4 | 0 | 0 |
| <a name="EOR">EOR</a> | $0200 | 0x4D | N Z | 4 | 0 | 0 |
| <a name="EOR">EOR</a> | $0200,X | 0x5D | N Z | 4 | 0 | 1 |
| <a name="EOR">EOR</a> | $0200,Y | 0x59 | N Z | 4 | 0 | 1 |
| <a name="EOR">EOR</a> | ($09),X | 0x41 | N Z | 6 | 0 | 0 |
| <a name="EOR">EOR</a> | ($09),Y | 0x51 | N Z | 5 | 0 | 1 |
| <a name="INC">INC</a> | $F9 | 0xE6 | N Z | 5 | 0 | 0 |
| <a name="INC">INC</a> | $F9,X | 0xF6 | N Z | 6 | 0 | 0 |
| <a name="INC">INC</a> | $0200 | 0xEE | N Z | 6 | 0 | 0 |
| <a name="INC">INC</a> | $0200,X | 0xFE | N Z | 7 | 0 | 0 |
| <a name="INX">INX</a> |   | 0xE8 |  | 2 | 0 | 0 |
| <a name="INY">INY</a> |   | 0xC8 |  | 2 | 0 | 0 |
| <a name="JMP">JMP</a> | $0200 | 0x4C |  | 3 | 0 | 0 |
| <a name="JMP">JMP</a> | ($0200) | 0x6C |  | 5 | 0 | 0 |
| <a name="JSR">JSR</a> | $0200 | 0x20 |  | 6 | 0 | 0 |
| <a name="LDA">LDA</a> | #09 or #$F9 | 0xA9 | N Z | 2 | 0 | 0 |
| <a name="LDA">LDA</a> | $F9 | 0xA5 | N Z | 3 | 0 | 0 |
| <a name="LDA">LDA</a> | $F9,X | 0xB5 | N Z | 4 | 0 | 0 |
| <a name="LDA">LDA</a> | $0200 | 0xAD | N Z | 4 | 0 | 0 |
| <a name="LDA">LDA</a> | $0200,X | 0xBD | N Z | 4 | 0 | 1 |
| <a name="LDA">LDA</a> | $0200,Y | 0xB9 | N Z | 4 | 0 | 1 |
| <a name="LDA">LDA</a> | ($09),X | 0xA1 | N Z | 6 | 0 | 0 |
| <a name="LDA">LDA</a> | ($09),Y | 0xB1 | N Z | 5 | 0 | 1 |
| <a name="LDX">LDX</a> | #09 or #$F9 | 0xA2 | N Z | 2 | 0 | 0 |
| <a name="LDX">LDX</a> | $F9 | 0xA6 | N Z | 3 | 0 | 0 |
| <a name="LDX">LDX</a> | $F9,Y | 0xB6 | N Z | 4 | 0 | 0 |
| <a name="LDX">LDX</a> | $0200 | 0xAE | N Z | 4 | 0 | 0 |
| <a name="LDX">LDX</a> | $0200,Y | 0xBE | N Z | 4 | 0 | 1 |
| <a name="LDY">LDY</a> | #09 or #$F9 | 0xA0 | N Z | 2 | 0 | 0 |
| <a name="LDY">LDY</a> | $F9 | 0xA4 | N Z | 3 | 0 | 0 |
| <a name="LDY">LDY</a> | $F9,X | 0xB4 | N Z | 4 | 0 | 0 |
| <a name="LDY">LDY</a> | $0200 | 0xAC | N Z | 4 | 0 | 0 |
| <a name="LDY">LDY</a> | $0200,X | 0xBC | N Z | 4 | 0 | 1 |
| <a name="LSR">LSR</a> |   | 0x4A | N Z C | 2 | 0 | 0 |
| <a name="LSR">LSR</a> | A | 0x4A | N Z C | 2 | 0 | 0 |
| <a name="LSR">LSR</a> | $F9 | 0x46 | N Z C | 5 | 0 | 0 |
| <a name="LSR">LSR</a> | $F9,X | 0x56 | N Z C | 6 | 0 | 0 |
| <a name="LSR">LSR</a> | $0200 | 0x4E | N Z C | 78 | 0 | 0 |
| <a name="LSR">LSR</a> | $0200,X | 0x5E | N Z C | 7 | 0 | 0 |
| <a name="NOP">NOP</a> |   | 0xEA |  | 2 | 0 | 0 |
| <a name="ORA">ORA</a> | #09 or #$F9 | 0x09 | N O Z | 2 | 0 | 0 |
| <a name="ORA">ORA</a> | $F9 | 0x05 | N O Z | 3 | 0 | 0 |
| <a name="ORA">ORA</a> | $F9,X | 0x15 | N O Z | 4 | 0 | 0 |
| <a name="ORA">ORA</a> | $0200 | 0x0D | N O Z | 4 | 0 | 0 |
| <a name="ORA">ORA</a> | $0200,X | 0x1D | N O Z | 4 | 0 | 1 |
| <a name="ORA">ORA</a> | $0200,Y | 0x19 | N O Z | 4 | 0 | 1 |
| <a name="ORA">ORA</a> | ($09),X | 0x01 | N O Z | 6 | 0 | 0 |
| <a name="ORA">ORA</a> | ($09),Y | 0x11 | N O Z | 5 | 0 | 1 |
| <a name="PHA">PHA</a> |   | 0x48 |  | 3 | 0 | 0 |
| <a name="PHP">PHP</a> |   | 0x08 |  | 3 | 0 | 0 |
| <a name="PLA">PLA</a> |   | 0x68 |  | 4 | 0 | 0 |
| <a name="PLP">PLP</a> |   | 0x28 |  | 4 | 0 | 0 |
| <a name="ROL">ROL</a> |   | 0x2A | N Z C | 2 | 0 | 0 |
| <a name="ROL">ROL</a> | A | 0x2A | N Z C | 2 | 0 | 0 |
| <a name="ROL">ROL</a> | $F9 | 0x26 | N Z C | 5 | 0 | 0 |
| <a name="ROL">ROL</a> | $F9,X | 0x36 | N Z C | 6 | 0 | 0 |
| <a name="ROL">ROL</a> | $0200 | 0x2E | N Z C | 6 | 0 | 0 |
| <a name="ROL">ROL</a> | $0200,X | 0x3E | N Z C | 7 | 0 | 0 |
| <a name="ROR">ROR</a> |   | 0x6A | N Z C | 2 | 0 | 0 |
| <a name="ROR">ROR</a> | A | 0x6A | N Z C | 2 | 0 | 0 |
| <a name="ROR">ROR</a> | $F9 | 0x66 | N Z C | 5 | 0 | 0 |
| <a name="ROR">ROR</a> | $F9,X | 0x76 | N Z C | 6 | 0 | 0 |
| <a name="ROR">ROR</a> | $0200 | 0x6E | N Z C | 6 | 0 | 0 |
| <a name="ROR">ROR</a> | $0200,X | 0x7E | N Z C | 7 | 0 | 0 |
| <a name="RTI">RTI</a> |   | 0x40 | N O - B D I Z C | 6 | 0 | 0 |
| <a name="RTS">RTS</a> |   | 0x60 | N O - B D I Z C | 6 | 0 | 0 |
| <a name="SBC">SBC</a> | #09 or #$F9 | 0xE9 | N O Z C | 2 | 0 | 0 |
| <a name="SBC">SBC</a> | $F9 | 0xE5 | N O Z C | 3 | 0 | 0 |
| <a name="SBC">SBC</a> | $F9,X | 0xF5 | N O Z C | 4 | 0 | 0 |
| <a name="SBC">SBC</a> | $0200 | 0xED | N O Z C | 4 | 0 | 0 |
| <a name="SBC">SBC</a> | $0200,X | 0xFD | N O Z C | 4 | 0 | 1 |
| <a name="SBC">SBC</a> | $0200,Y | 0xF9 | N O Z C | 4 | 0 | 1 |
| <a name="SBC">SBC</a> | ($09),X | 0xE1 | N O Z C | 6 | 0 | 0 |
| <a name="SBC">SBC</a> | ($09),Y | 0xF1 | N O Z C | 5 | 0 | 1 |
| <a name="SEC">SEC</a> |   | 0x38 | C | 2 | 0 | 0 |
| <a name="SED">SED</a> |   | 0xF8 | D | 2 | 0 | 0 |
| <a name="SEI">SEI</a> |   | 0x78 | I | 2 | 0 | 0 |
| <a name="STA">STA</a> | $F9 | 0x85 |  | 3 | 0 | 0 |
| <a name="STA">STA</a> | $F9,X | 0x95 |  | 4 | 0 | 0 |
| <a name="STA">STA</a> | $0200 | 0x8D |  | 4 | 0 | 0 |
| <a name="STA">STA</a> | $0200,X | 0x9D |  | 5 | 0 | 0 |
| <a name="STA">STA</a> | $0200,Y | 0x99 |  | 5 | 0 | 0 |
| <a name="STA">STA</a> | ($09),X | 0x81 |  | 6 | 0 | 0 |
| <a name="STA">STA</a> | ($09),Y | 0x91 |  | 6 | 0 | 0 |
| <a name="STX">STX</a> | $F9 | 0x86 |  | 3 | 0 | 0 |
| <a name="STX">STX</a> | $F9,Y | 0x96 |  | 4 | 0 | 0 |
| <a name="STX">STX</a> | $0200 | 0x8E |  | 4 | 0 | 0 |
| <a name="STY">STY</a> | $F9 | 0x84 |  | 3 | 0 | 0 |
| <a name="STY">STY</a> | $F9,X | 0x94 |  | 4 | 0 | 0 |
| <a name="STY">STY</a> | $0200 | 0x8C |  | 4 | 0 | 0 |
| <a name="TAX">TAX</a> |   | 0xAA |  | 2 | 0 | 0 |
| <a name="TAY">TAY</a> |   | 0xA8 |  | 2 | 0 | 0 |
| <a name="TSX">TSX</a> |   | 0xBA |  | 2 | 0 | 0 |
| <a name="TXA">TXA</a> |   | 0x8A |  | 2 | 0 | 0 |
| <a name="TXS">TXS</a> |   | 0x9A |  | 2 | 0 | 0 |
| <a name="TYA">TYA</a> |   | 0x98 |  | 2 | 0 | 0 |
