---
title: x64 Assembly & OpenGL
description: x64 Assembly programming and calling OpenGL (Open Graphics Library) to render some cool stuff in a window
tags: x64, assembly, masm, opengl, graphics, window, drawing, visual studio
image: https://i.imgur.com/bQfW9zf.png
date: 11/29/2019
---

Something I've been really wanting to do is to create a simple game in Assembly (any platform might do). One of the problems I was having was trying to figure out what platform I wanted to create the game for. My ideal platform would be a 16-bit platform because I loved that era of games, but at the same time, I want to be able to use modern tools and debuggers. I think the next best thing would just be to develop a game on a modern CPU; so I decided that I'll just assemble my game for the x64 architecture.

**JMP**
- [How to render graphics](#how-to-render-graphics)
- [Tools & libs needed](#tools--libs-needed)
- [Main file](#main-file)
- [Calling GLFW initialize to check setup](#calling-glfw-initialize-to-check-setup)
- [Getting a window showing up](#getting-a-window-showing-up)

## How to render graphics!?
Well, one of the more complicated problems when it comes to modern computers is that they are very complex and hidden behind endless layers of programs running on the OS it has to run through. Days of being able to just take control of the machine to run your programs have been long gone and isn't coming back (except in homebrew stuff). This brings up a pretty big question, "how to render to screen?". Well, as I was saying, computers have become vastly more complicated in recent years and there is a lot of wordy documentation but not much tutorial-like material. In order to get to the" meat and potatoes" of of writing a game, I've decided that I'll work with existing libraries for OpenGL and operating system events/windowing.

Okay, enough of the jabber, lets just come out and say exactly how we are going to make a game in x64 assembly. The answer is to use pre-compiled libraries like GLFW, Freetype and FMOD. That is not to say that we are going to do any of the programming in C (even though those libraries were developed in C). We are just going to use their compiled machine code for our purposese. Since these are C compiled functions, we are going to need to follow the [fast-call calling convention](x64-assembly.md#fast-call-procedure-calling-conventions) for x64 assembly.

I must admit, using libraries like these isn't exactly as exciting as writing direct video memory for rendering; but at least the standard calling conventions exist for C to enable us to be able to develop a game in x64 Assembly and get past the complexities that operating systems and graphics cards have. Maybe later, once I have more experience in x64 assembly I'd be willing to go through and write some of those routines, but for now, we'll just stick to basic graphics and game logic routines.

## Tools & libs needed
- [Visual Studio](https://visualstudio.microsoft.com/vs/community/)
- [GLFW 64-bit](https://www.glfw.org/)
- [FreeType](https://www.freetype.org/)
- [FMOD](https://www.fmod.com/)

If you don't know how to setup Visual Studio for x64 Assembly development, I've described it with some pictures at [this link](hx64-assembly.md#setting-up-a-x64-only-project-in-visual-studio) so check that out first.

I might come back and update this on how to get the libs setup for usage, however you just need to set them up the same exact way you would set them up in C/C++ so any guide on how to do that will suffice for now. I've got some stuff I want to type out here first to get things going.

## Main file
The entry point for our program is going to be `main` just as described in the example on how to setup x64 assembly. There are a few libraries that you need to include before we can start using the various 3rd party dependencies that we've downloaded. Below is the bare bones **main.asm** file that we need to get started.
```nasm
includelib legacy_stdio_definitions.lib	; printf, etc.
includelib ucrt.lib			; malloc, calloc, free, etc.
includelib vcruntime.lib		; memcpy, strstr, etc.

extern ExitProcess: PROC		; Windows function for exiting process

.code
main PROC			; The entry point for our application
	and rsp, not 08h	; Make sure that the stack is 16-byte aligned
	sub rsp, 20h		; Shadow space (+8 bytes) for following call
	call ExitProcess	; Exit our application
main ENDP
END
```
As you can see, since we are using libraries that were developed in C, we also need to include the standard C runtime libraries. There are functions like `HeapAlloc` that Windows offers, which then we wouldn't need to include these libraries; however, most C libraries (such as the ones we are using) use the C standard library functions. If you compile and run  this program, it should open and close as it does nothing but exit itself, but no errors is the key here.

**NOTE:** If you get an error like `unresolved external symbol __imp___CrtDbgReportW`, be sure to check out the **NOTE** that is near the end of the [visual studio x64 assembly setup](hx64-assembly.md#setting-up-a-x64-only-project-in-visual-studio) tutorial.

## Calling GLFW initialize to check setup
Now that we have the libraries setup and included all the libs that we needed, lets make sure everything is working by making a call to initialize GLFW and see the response code.
```nasm
includelib legacy_stdio_definitions.lib	; printf, etc.
includelib ucrt.lib			; malloc, calloc, free, etc.
includelib vcruntime.lib		; memcpy, strstr, etc.

extern ExitProcess: PROC	; Windows function for exiting process
extern glfwInit: PROC		; The C glfwInit function

.code
main PROC			; The entry point for our application
	and rsp, not 08h	; Make sure that the stack is 16-byte aligned
	sub rsp, 20h		; Shadow space (+8 bytes) for the glfwInit call
	call glfwInit		; Call glfwInit and check response
	add rsp, 20h		; Remove the shadow space that was added
	; TODO:  Put a breakpoint on the above or below line and look at RAX
	; RAX should hold the value 01h
	sub rsp, 20h		; Shadow space (+8 bytes) for following call
	call ExitProcess	; Exit our application
main ENDP
END
```
Below you'll see that I placed a breakpoint after calling the glfwInit function and if you look at the value in `RAX` you will see `01h` which means it was successfully initialized.

![glfwInit in x64 assembly should be 01h](https://i.imgur.com/bQfW9zf.png)

## Getting a window showing up
TBD
