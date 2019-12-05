---
title: Writing a 6502 Assembler
description: Going through and explaining the 6502 assembler that I wrote.
tags: 6502 assembly assembler writing-6502 writing-assembler
---

So last night I wrote a 6502 Assembler which uses the same syntax you would find in most online tutorials like [this one](https://skilldrick.github.io/easy6502/index.html). There are still some things I need to add to it such as the `BCD` instruction and the `#>`/`#<` symbols for addresses and labels. I also wrote the code in a way that would allow me to output useful information about the language such as the following table.

I'm going to come back and update this when I have a bit more time, but I can at least drop the table for reference.

| Mnemonic | Argument | OpCode | Flags | Clock | SkipClock | BoundsClock |
| :------: | :------: | :----: | :---: | :---: | :-------: | :---------: |
| ADC | #09 or #$F9 | 105 | N O Z C | 2 | 0 | 0 |
| ADC | $F9 | 101 | N O Z C | 3 | 0 | 0 |
| ADC | $F9,X | 117 | N O Z C | 4 | 0 | 0 |
| ADC | $0200 | 109 | N O Z C | 4 | 0 | 0 |
| ADC | $0200,X | 125 | N O Z C | 4 | 0 | 1 |
| ADC | $0200,Y | 121 | N O Z C | 4 | 0 | 1 |
| ADC | ($09),X | 97 | N O Z C | 6 | 0 | 0 |
| ADC | ($09),Y | 113 | N O Z C | 5 | 0 | 1 |
| AND | #09 or #$F9 | 41 | N Z | 2 | 0 | 0 |
| AND | $F9 | 37 | N Z | 3 | 0 | 0 |
| AND | $F9,X | 53 | N Z | 4 | 0 | 0 |
| AND | $0200 | 45 | N Z | 4 | 0 | 0 |
| AND | $0200,X | 61 | N Z | 4 | 0 | 1 |
| AND | $0200,Y | 57 | N Z | 4 | 0 | 1 |
| AND | ($09),X | 33 | N Z | 6 | 0 | 0 |
| AND | ($09),Y | 49 | N Z | 5 | 0 | 1 |
| ASL |   | 10 | N Z C | 2 | 0 | 0 |
| ASL | A | 10 | N Z C | 2 | 0 | 0 |
| ASL | $F9 | 6 | N Z C | 5 | 0 | 0 |
| ASL | $F9,X | 22 | N Z C | 6 | 0 | 0 |
| ASL | $0200 | 14 | N Z C | 6 | 0 | 0 |
| ASL | $0200,X | 30 | N Z C | 7 | 0 | 0 |
| BCC | $0200 | 144 |  | 1 | 1 | 1 |
| BCS | $0200 | 176 |  | 1 | 1 | 1 |
| BEQ | $0200 | 240 |  | 1 | 1 | 1 |
| BIT | $F9 | 36 | N O Z | 3 | 0 | 0 |
| BIT | $0200 | 44 | N O Z | 3 | 0 | 0 |
| BMI | $0200 | 48 |  | 1 | 1 | 1 |
| BNE | $0200 | 208 |  | 1 | 1 | 1 |
| BPL | $0200 | 16 |  | 1 | 1 | 1 |
| BRK |   | 0 |  | 7 | 0 | 0 |
| BVC | $0200 | 80 |  | 1 | 1 | 1 |
| BVS | $0200 | 112 |  | 1 | 1 | 1 |
| CLC |   | 24 | C | 2 | 0 | 0 |
| CLD |   | 216 | D | 2 | 0 | 0 |
| CLI |   | 88 | I | 2 | 0 | 0 |
| CLV |   | 184 | O | 2 | 0 | 0 |
| CMP | #09 or #$F9 | 201 |  | 2 | 0 | 0 |
| CMP | $F9 | 197 |  | 3 | 0 | 0 |
| CMP | $F9,X | 213 |  | 4 | 0 | 0 |
| CMP | $0200 | 205 |  | 4 | 0 | 0 |
| CMP | $0200,X | 221 |  | 4 | 0 | 1 |
| CMP | $0200,Y | 217 |  | 4 | 0 | 1 |
| CMP | ($09),X | 193 |  | 6 | 0 | 0 |
| CMP | ($09),Y | 209 |  | 5 | 0 | 1 |
| CPX | #09 or #$F9 | 224 | N Z C | 2 | 0 | 0 |
| CPX | $F9 | 228 | N Z C | 3 | 0 | 0 |
| CPX | $0200 | 236 | N Z C | 4 | 0 | 0 |
| CPY | #09 or #$F9 | 192 | N Z C | 2 | 0 | 0 |
| CPY | $F9 | 196 | N Z C | 3 | 0 | 0 |
| CPY | $0200 | 204 | N Z C | 4 | 0 | 0 |
| DEC | $F9 | 198 | N Z | 5 | 0 | 0 |
| DEC | $F9,X | 214 | N Z | 6 | 0 | 0 |
| DEC | $0200 | 206 | N Z | 6 | 0 | 0 |
| DEC | $0200,X | 222 | N Z | 7 | 0 | 0 |
| DEX |   | 202 |  | 2 | 0 | 0 |
| DEY |   | 136 |  | 2 | 0 | 0 |
| EOR | #09 or #$F9 | 73 | N Z | 2 | 0 | 0 |
| EOR | $F9 | 69 | N Z | 3 | 0 | 0 |
| EOR | $F9,X | 85 | N Z | 4 | 0 | 0 |
| EOR | $0200 | 77 | N Z | 4 | 0 | 0 |
| EOR | $0200,X | 93 | N Z | 4 | 0 | 1 |
| EOR | $0200,Y | 89 | N Z | 4 | 0 | 1 |
| EOR | ($09),X | 65 | N Z | 6 | 0 | 0 |
| EOR | ($09),Y | 81 | N Z | 5 | 0 | 1 |
| INC | $F9 | 230 | N Z | 5 | 0 | 0 |
| INC | $F9,X | 246 | N Z | 6 | 0 | 0 |
| INC | $0200 | 238 | N Z | 6 | 0 | 0 |
| INC | $0200,X | 254 | N Z | 7 | 0 | 0 |
| INX |   | 232 |  | 2 | 0 | 0 |
| INY |   | 200 |  | 2 | 0 | 0 |
| JMP | $0200 | 76 |  | 3 | 0 | 0 |
| JMP | ($0200) | 108 |  | 5 | 0 | 0 |
| JSR | $0200 | 32 |  | 6 | 0 | 0 |
| LDA | #09 or #$F9 | 169 | N Z | 2 | 0 | 0 |
| LDA | $F9 | 165 | N Z | 3 | 0 | 0 |
| LDA | $F9,X | 181 | N Z | 4 | 0 | 0 |
| LDA | $0200 | 173 | N Z | 4 | 0 | 0 |
| LDA | $0200,X | 189 | N Z | 4 | 0 | 1 |
| LDA | $0200,Y | 185 | N Z | 4 | 0 | 1 |
| LDA | ($09),X | 161 | N Z | 6 | 0 | 0 |
| LDA | ($09),Y | 177 | N Z | 5 | 0 | 1 |
| LDX | #09 or #$F9 | 162 | N Z | 2 | 0 | 0 |
| LDX | $F9 | 166 | N Z | 3 | 0 | 0 |
| LDX | $F9,Y | 182 | N Z | 4 | 0 | 0 |
| LDX | $0200 | 174 | N Z | 4 | 0 | 0 |
| LDX | $0200,Y | 190 | N Z | 4 | 0 | 1 |
| LDY | #09 or #$F9 | 160 | N Z | 2 | 0 | 0 |
| LDY | $F9 | 164 | N Z | 3 | 0 | 0 |
| LDY | $F9,X | 180 | N Z | 4 | 0 | 0 |
| LDY | $0200 | 172 | N Z | 4 | 0 | 0 |
| LDY | $0200,X | 188 | N Z | 4 | 0 | 1 |
| LSR |   | 74 | N Z C | 2 | 0 | 0 |
| LSR | A | 74 | N Z C | 2 | 0 | 0 |
| LSR | $F9 | 70 | N Z C | 5 | 0 | 0 |
| LSR | $F9,X | 86 | N Z C | 6 | 0 | 0 |
| LSR | $0200 | 78 | N Z C | 78 | 0 | 0 |
| LSR | $0200,X | 94 | N Z C | 7 | 0 | 0 |
| NOP |   | 234 |  | 2 | 0 | 0 |
| ORA | #09 or #$F9 | 9 | N O Z | 2 | 0 | 0 |
| ORA | $F9 | 5 | N O Z | 3 | 0 | 0 |
| ORA | $F9,X | 21 | N O Z | 4 | 0 | 0 |
| ORA | $0200 | 13 | N O Z | 4 | 0 | 0 |
| ORA | $0200,X | 29 | N O Z | 4 | 0 | 1 |
| ORA | $0200,Y | 25 | N O Z | 4 | 0 | 1 |
| ORA | ($09),X | 1 | N O Z | 6 | 0 | 0 |
| ORA | ($09),Y | 17 | N O Z | 5 | 0 | 1 |
| PHA |   | 72 |  | 3 | 0 | 0 |
| PHP |   | 8 |  | 3 | 0 | 0 |
| PLA |   | 104 |  | 4 | 0 | 0 |
| PLP |   | 40 |  | 4 | 0 | 0 |
| ROL |   | 42 | N Z C | 2 | 0 | 0 |
| ROL | A | 42 | N Z C | 2 | 0 | 0 |
| ROL | $F9 | 38 | N Z C | 5 | 0 | 0 |
| ROL | $F9,X | 54 | N Z C | 6 | 0 | 0 |
| ROL | $0200 | 46 | N Z C | 6 | 0 | 0 |
| ROL | $0200,X | 62 | N Z C | 7 | 0 | 0 |
| ROR |   | 106 | N Z C | 2 | 0 | 0 |
| ROR | A | 106 | N Z C | 2 | 0 | 0 |
| ROR | $F9 | 102 | N Z C | 5 | 0 | 0 |
| ROR | $F9,X | 118 | N Z C | 6 | 0 | 0 |
| ROR | $0200 | 110 | N Z C | 6 | 0 | 0 |
| ROR | $0200,X | 126 | N Z C | 7 | 0 | 0 |
| RTI |   | 64 | N O - B D I Z C | 6 | 0 | 0 |
| RTS |   | 96 | N O - B D I Z C | 6 | 0 | 0 |
| SBC | #09 or #$F9 | 233 | N O Z C | 2 | 0 | 0 |
| SBC | $F9 | 229 | N O Z C | 3 | 0 | 0 |
| SBC | $F9,X | 245 | N O Z C | 4 | 0 | 0 |
| SBC | $0200 | 237 | N O Z C | 4 | 0 | 0 |
| SBC | $0200,X | 253 | N O Z C | 4 | 0 | 1 |
| SBC | $0200,Y | 249 | N O Z C | 4 | 0 | 1 |
| SBC | ($09),X | 225 | N O Z C | 6 | 0 | 0 |
| SBC | ($09),Y | 241 | N O Z C | 5 | 0 | 1 |
| SEC |   | 56 | C | 2 | 0 | 0 |
| SED |   | 248 | D | 2 | 0 | 0 |
| SEI |   | 120 | I | 2 | 0 | 0 |
| STA | $F9 | 133 |  | 3 | 0 | 0 |
| STA | $F9,X | 149 |  | 4 | 0 | 0 |
| STA | $0200 | 141 |  | 4 | 0 | 0 |
| STA | $0200,X | 157 |  | 5 | 0 | 0 |
| STA | $0200,Y | 153 |  | 5 | 0 | 0 |
| STA | ($09),X | 129 |  | 6 | 0 | 0 |
| STA | ($09),Y | 145 |  | 6 | 0 | 0 |
| STX | $F9 | 134 |  | 3 | 0 | 0 |
| STX | $F9,Y | 150 |  | 4 | 0 | 0 |
| STX | $0200 | 142 |  | 4 | 0 | 0 |
| STY | $F9 | 132 |  | 3 | 0 | 0 |
| STY | $F9,X | 148 |  | 4 | 0 | 0 |
| STY | $0200 | 140 |  | 4 | 0 | 0 |
| TAX |   | 170 |  | 2 | 0 | 0 |
| TAY |   | 168 |  | 2 | 0 | 0 |
| TSX |   | 186 |  | 2 | 0 | 0 |
| TXA |   | 138 |  | 2 | 0 | 0 |
| TXS |   | 154 |  | 2 | 0 | 0 |
| TYA |   | 152 |  | 2 | 0 | 0 |
