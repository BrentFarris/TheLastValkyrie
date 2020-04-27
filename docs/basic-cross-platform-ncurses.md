---
title: Basic Cross Platform ncurses
description: I'm currently trying to write a terminal/console application in C that works on both Windows and Linux but my problem is ncurses is not on windows
tags: c c-programming cross-platform ncurses windows command-prompt cmd
---

I'm currently in the process of writing my LTTP (Lightweight Text Transfer Protocol) and in the process of creating a text-based client I hit a snag where I needed `ncurses` functionality but I also didn't want people on Windows to need to enable the Linux subsystem in Windows 10 in order to use the lttp client. For this I wrapped some of the most primitive functions that I needed for both ncurses and the [Windows Console API](https://docs.microsoft.com/en-us/windows/console/console-functions).

For anyone looking to do the same thing and wanting to save a few minutes of not having to write a wrapper yourself, you can find the C code on my LTTP GitHub repository. Here is the [header file](https://github.com/BrentFarris/lttp/blob/master/src/client/display.h) and here is the [code file](https://github.com/BrentFarris/lttp/blob/master/src/client/display.c), feel free to copy them and use/modify them as you wish!

I did not spend a ton of time on this wrapper (just a single afternoon of reading both documentations and writing it). So if you make any fixes or upgrades, I would love for you to shoot them my way!
