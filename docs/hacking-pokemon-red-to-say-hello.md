---
title: Hacking Pokemon Red to say Hello! - Game Boy
description: I decided, for fun, to hack Pokemon Red Version for the Game Boy and change it's code to say hello. I'll go through what I did, how I did it, and even the mistakes I made.
tags: game boy, gameboy, hacking, reverse engineering, pokemon, pokemon red
image: https://spee.ch/1/d645e087ad106b01.png
date: 11/19/2021
---

I created a video showing how to do a little bit of hacking/reverse programming on the Game Boy game Pokemon Red Version. This is a simple hack where we replace some text in the ROM. This video is not intended to be a tutorial, it is really just me setting down and recording myself going through the process of doing this hack. I've never done this particular kind of thing before on a Game Boy ROM so in a way we are learning it together.

## The video
<div style="width:100%;padding-top:56.25%;position:relative;">
<iframe id="lbry-iframe" style="min-width:100%;min-height:100%;position:absolute;top:0;" src="https://odysee.com/$/embed/hacking-pokemon-red-to-say-hello/e762bf1ad017d3272ae54ec92fcff650ee31a9cc?r=9NYwemPGdWZFVx6iX9LUNBPERbgCcmQ2" allowfullscreen></iframe>
</div>

## The tools
1. Debugger - [No$GMB](https://problemkaputt.de/gmb.htm)
2. Tile editor - [Tile Designer](https://www.devrs.com/gb/hmgd/gbtd.html)
3. Text editor - [VS Code](https://code.visualstudio.com/)
4. Hex editor - [VS Code Hex Editor Plugin](https://marketplace.visualstudio.com/items?itemName=ms-vscode.hexeditor)
5. C compiler - [Clang](https://clang.llvm.org/)
6. C check sum program - [Sum C program code](https://gist.github.com/BrentFarris/28ab8529b2d2d74fcdaa56708f66e4d9)

## TLDR; Steps
1. Get your personal Pokemon Red Version Rom
2. Create a copy of it and name it `original.gb` in case of mistakes
4. Open the Tile editor and create 1-11 tiles of whatever you wish
5. Export all 11 tiles (even if you didn't use 11) to a binary file
6. Copy the binary output in a hex editor
7. Open the Pokemon Red rom (not `original.gb`)
8. Locate address `0x000121F9`
9. Overwrite the values with the values from your binary file
10. Copy [this C program code](https://gist.github.com/BrentFarris/28ab8529b2d2d74fcdaa56708f66e4d9) to a file
11. Compile the c code using Clang
12. Pass your modified Pokemon Red rom into the compiled program
13. Copy the last 4 numbers (2 bytes) of the `Sum:` output
14. Open the Pokemon Red rom (not `original.gb`)
15. Locate address `0x0000014E` and `0x0000014F`
16. Replace those 2 bytes with the value you copied from the output of the program
17. Save the rom
18. Play the rom again in the debugger
