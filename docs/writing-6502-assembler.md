---
title: Writing a 6502 Assembler
description: Going through and explaining the 6502 assembler that I wrote.
tags: 6502 assembly assembler writing-6502 writing-assembler
---

So I wrote a 6502 Assembler which uses the same syntax you would find in most online tutorials like [this one](https://skilldrick.github.io/easy6502/index.html).

**JMP**
- [Setting the program offset](#setting-the-program-offset)
- [Special instruction DCB](#special-instruction-dcb)
- [Special symbols (#< and #>)](#special-symbols--and-)

## Setting the program offset
TBD

## Special instruction DCB
TBD

## Special symbols (#< and #>)
TBD

I'm going to come back and update this when I have a bit more time, but I can at least drop the table for reference.

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
