---
title: Game Boy Assembler & Emulator/Debugger
description: So I wrote a Game Boy assembler and emulator/debugger to make it easier to debug 
tags: game-boy gameboy assembler emulator z80 debugger
---

I've been having some fun writing a Game Boy game with a co-worker, nothing fancy, just for fun to learn more about the Game Boy and teaching my co-worker how to write games for it in assembly. One of the problems we have is that the tools we use to debug the code are a little difficult to use. Basically you have to run it in an emulator/debugger like No$GMB and then hit break points and review the state of the device. I thought it would be really cool to just write assertions directly into the assembly code and have it tell me when things are wrong. Basically like unit testing the Game Boy code.

So I wrote both a non-graphical **emulator** and a custom **assembler** for the Game Boy.

**JMP**
- [The Emulator](#the-emulator)
- [The Assembler](#the-assembler)
- [Writing Assertions](#writing-assertions)
- [Available Assertions](#available-assertions)
- [Game Boy OpCodes](#game-boy-opcodes)

## The Emulator
The emulator is being developed in C for maximum portability. I mainly wrote the emulator for debugging purposes. I wanted an easy way to test subroutines for the Game Boy without having to load up a big graphical debugger in order to do so. Also those debuggers often lack the things I would like where are mainly assertions to prove that values are what they should be at a given point in the code/memory. So this emulator is not a graphical emulator and I still have yet to do any of the timing based parts of the Game Boy to call it a complete emulator. What it is good at right now is being able to run the opcode instructions given to it and manipulate registers and memory.

## The Assembler
The assembler is being developed in C for maximum portability as well. In order to be able to make assertions directly in the code, it was important for me to write my own Assembler. It currently does not have any support for macros, `IF` statements or any fancy math, but it does have the ability to assemble the z80 code and labels into code that the emulator can run and test against. All of the Game Boy instruction set is supported in the current build of the Assembler and subroutines (with dot labels) are supported as well in order to be able to test loops, jumps and all that sort of stuff easily. It also strips comments from the code as well.

## Writing Assertions
Here is an example of what the Assembler can do with assertions.
```assembly
; Subtract BC from HL and store the result in HL
HL_minus_BC::
	ld hl, $1104	; Our test LHS
	ld bc, $1005	; Our test RHS
	
	push af
	ld a, l			; Get low byte
	sub c			; Subtract rhs low byte
	jr nc, .skip	; If we didn't go negative, jump to skip
	dec h			; Otherwise we decrement high byte
.skip
	ld l, a			; Set low byte to new value
	ld a, h			; Get high byte
	sub b			; Subtract rhs high byte
	ld h, a			; Set high byte to new value
	pop af
	assert eq hl, $00FF
```
What you will see in the code above we have a line `assert eq hl, $00FF`. This will test the code immediately after `pop af` has ran to determine if the value in `HL` is euqal to the value `$00FF`. This will then print out to the console if the assertian has passed or failed. This allows for quickly testing out subroutines to make sure they work as expected.

## Available Assertions
Below are 3 tables, the first table is explaining the syntax used, the second is the comparison options, and the third are the actual assertions (reference the 2 tables above it).

**Keywords**

| Keyword | Description |
| :------: | :------ |
| R | Any 8-bit register (a, f, b, c, d, e, h, l) |
| RR | Any 16-bit register pair (af, bc, de, hl) |
| %x | Any 8-bit number (5, $3A) |
| %xx | Any 16-bit number (536, $3A9E) |
| <=> | Comparison operator (eq, neq, leq, geq, lt, gt) |

**Comparison operators**

| Keyword | Description |
| :------: | :------ |
| eq | Are equal |
| neq | Are not equal |
| leq | Left is less than or equal to right |
| geq | Left is greater than or equal to right |
| lt | Left is less than right |
| gt | Left is greater than right |

**Assertion instructions**

| Format | Example | Description |
| :------: | :------ | :--------- |
| assert <=> R, %x | `assert eq a, $3F` | Compares a register to an 8-bit value |
| assert <=> R, R | `assert neq b, e` | Compares the value of 2 registers |
| assert <=> RR, RR | `assert leq bc, de` | Compares the values of 2 16-bit register pairs |
| assert <=> RR, %xx | `assert geq de, $020F` | Compares the values of a 16-bit register to a 16-bit value |
| assert <=> [RR], %x | `assert lt [hl], $03` | Compares the value in memory at address held in 16-bit register pair to an 8-bit value |
| assert <=> [RR], R | `assert gt [hl], e` | Compares the value in memory at address held in 16-bit register pair to a register value |
| assert <=> [%xx], %x | `assert eq [$3F9A], $09` | Compares the value in memory at address to an 8-bit value |
| assert <=> [%xx], R | `assert eq [$2000], a` | Compares the value in memory at address to a register value |

## Game Boy OpCodes
TBD
