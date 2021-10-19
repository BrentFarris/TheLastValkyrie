---
title: C++ Shortcomings
description: Some issues with C++ when it comes to developing libraries that others can use
tags: c++ c++-programming tips c++-issues dll-issues
---

Before we begin, I'll be the first to tell you that I love C++, it is a great OOP language with a vast feature set. It is also one of my most favorite languages, second only to C. It's vast amount of features can be one of it's crippling issues when it comes to new developers learning it. Many developers over-use it's features or select the wrong tool for the job due to this. However, what I mainly want to focus on here is the troubles I've had with C++ while developing a GUI based game engine in C++. I've moved all of the code for my engine to C because of these shortcomings and to be able to expand the engine for games faster.

**JMP**
- [Background information](#background-information)
- [The V-Table](#the-v-table)
- [The ABI](#the-abi)


## Background information
So to understand the topics to follow on why C++ has some shortcomings, I first should provide some background information. At one point I was interested in using GTK to create a graphical interface for my game engine so that a developer can write C++ code as a plugin for the gameplay as an option. This is a typical game engine where you can drag and drop objects, view them in a hierarchy, and modify their properties, shaders, etc. in a point-and-click style UI. Everything was going just fine, until it came to the C++ as gameplay code part. I was able to compile gameplay code in C++ just fine, however I reliased a bit late that other people who use the engine would have to use the same exact compiler and version of the comipler to make sure everything goes smooth. To explain this, I'll reference 2 major issues below.

## The V-Table
The V-Table is what gives C++ it's magic ability to point objects to functions that operate on their members. The major problem here is that the V-Table is not a standard in C++. This means that some compilers could put it at the bottom top of the binary structure, where others could put it at the bottom, or even in the middle if they were really crazy. For those of you who use C and not C++, the V-Table can be visualized as a function pointer to a function that operates on the structure's instance. This table is a collection of the function pointers for a structure. Now being avid in C you know it is critical to know if this function table is going to be at the beginning or the end of a structure. If you were to serialize this structure for later reading or to send over the network, you will need to know how to reliably construct it on the other side. In C we take this for granted, the binary structure on the other side can easily be the same if the same struct is compiled in any C compiler. 

## The ABI
