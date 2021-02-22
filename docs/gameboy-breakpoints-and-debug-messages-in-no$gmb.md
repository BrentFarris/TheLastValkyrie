---
title: Gameboy breakpoints and debug messages in NO$GMB
description: Quick tip on how to do debug messages and breakpoints in NO$GMB Gameboy emulator and debugger using RGBDS
tags: gameboy no$gmb debug-messages breakpoints
image: https://i.imgur.com/0NiEvZu.png
---

<div style="width:100%;padding-top:56.25%;position:relative;">
<iframe id="lbry-iframe" style="min-width:100%;min-height:100%;position:absolute;top:0;" src="https://odysee.com/$/embed/gameboy-breakpoints-and-debug-messages-in-no-cash-gmb/2644dc9435274b58e835a0d35d54e6d8ab38928b?r=HP6i9hAVyEHmNWQo8j6iFo61fKRDg6G9" allowfullscreen></iframe>
</div>

The first thing you need to do is to turn on both breakpoints and debug messages inside of NO$GMB. To do this, open NO$GMB (a game does not need to be loaded) and then select `Options` in the top bar, then select `Debug eXception Setup` option. You will see the below window (mostly grayed out). Just select the following checkboxes to turn enable them:
1. Enable User Settings
2. Halt on 40h (ld b, b) (inside of "Source Code Breakpoints" area)
3. Write to Message Window (inside of "Debug Messages 52h (ld d, d)" area)

![NO$GMB debug messages and breakpoints settings window](https://i.imgur.com/3xniIor.png)

Below is the `MACRO` for the RGBDS assembler for being able to print debug messages to teh NO$GMB Gameboy emulator/debugger.
```assembly
IF !DEF(DEBUG_INC)
DEBUG_INC SET 1
; Prints a message to the no$gmb / bgb debugger
; Accepts a string as input, see emulator doc for support
DBGMSG: MACRO
	ld  d, d
	jr .end\@
	DB $64, $64, $00, $00
	DB \1
.end\@:
	ENDM
ENDC ; DEBUG_INC
```

Below is an example of how you can print a message and then trigger a breakpoint after the message prints.
```assembly
DBGMSG "This will print to a debug window"
ld b, b			; Triggers a breakpoint
```
