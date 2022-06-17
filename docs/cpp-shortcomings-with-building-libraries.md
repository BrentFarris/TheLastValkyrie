---
title: C++ Shortcomings With Building Libraries
description: Some issues with C++ when it comes to developing libraries that others can use
tags: c++, c++ programming, tips, c++ issues, dll issues
date: August 15, 2021
---

Before we begin, I'll be the first to tell you that I love C++, it is a great OOP language with a vast feature set. It is also one of my most favorite languages, second only to C. It's vast amount of features can be one of it's crippling issues when it comes to new developers learning it. Many developers over-use it's features or select the wrong tool for the job due to this. However, what I mainly want to focus on here is the troubles I've had with C++ while developing a GUI based game engine in C++. I've moved all of the code for my engine to C because of these shortcomings and to be able to expand the engine for games faster as a solo developer.

*Note:  All of the listed "shortcomings" really are because there isn't an ISO standard addressing them*

**JMP**
- [Background information](#background-information)
- [The V-Table](#the-v-table)
- [Name mangling](#name-mangling)
- [The ABI](#the-abi)
- [Conclusion](#conclusion)


## Background information
So to understand the topics to follow on why C++ has some shortcomings, I first should provide some background information. At one point I was interested in using GTK to create a graphical interface for my game engine so that a developer can write C++ code as a plugin for the gameplay as an option. This is a typical game engine where you can drag and drop objects, view them in a hierarchy, and modify their properties, shaders, etc. in a point-and-click style UI. Everything was going just fine, until it came to the C++ as gameplay code part. I was able to compile gameplay code in C++ just fine, however I reliased a bit late that other people who use the engine would have to use the same exact compiler and version of the comipler to make sure everything goes smooth. To explain this, I'll reference 2 major issues below.

## The V-Table
The V-Table is what gives C++ it's magic ability to point objects to functions that operate on their members. The major problem here is that the V-Table is not a standard in C++. This means that some compilers could put it at the bottom top of the binary structure, where others could put it at the bottom, or even in the middle if they were really crazy. For those of you who use C and not C++, the V-Table can be visualized as a function pointer to a function that operates on the structure's instance. This table is a collection of the function pointers for a structure. Now being avid in C you know it is critical to know if this function table is going to be at the beginning or the end of a structure. If you were to serialize this structure for later reading or to send over the network, you will need to know how to reliably construct it on the other side. In C we take this for granted, the binary structure on the other side can easily be the same if the same struct is compiled in any C compiler. Now imagine you had a compiler that mixed up the structure on the other side, you will wind up clobbering other fields in the structure. For this reason, you should compile all your C++ code using the same compiler or force a very strict ABI.

## Name mangling
[Name mangling](https://www.ibm.com/docs/en/i/7.4?topic=linkage-name-mangling-c-only) is a feature in C++ that allows you to have many functions with the same name. This enables overriding of functions so that a function with the same name could have different return types and arguments. This is a great feature to reduce similar-but-different functions, however it becomes a huge problem when developing a library that you would share. The problem here is that there are no rules for name mangling, what's worse is that the same compiler may produce a different name internally for a function on re-compilation. In C, since there isn't a feature for function overriding, the function name in the library is not mangled, in fact this is part of the ISO standard. This allows libraries to be updated without fear of breaking function names, unless you change it of course. That being said, you can use `extern "C"` in C++ to overcome this issue, which I did for a while but it becomes messy.

## The ABI
What is the ABI? It is the application binary interface. There is no standard in C++ for the ABI as there is in C. In C, the order you put the fields into your struct is the binary order they will be in. This does cause issues with memory boundaries if you were to put say a boolean as the first field and a pointer as the second. This would require you to pack your structure so that the space after the boolean is properly taken up. One of the rules in my [C rules post about big types first](brents-c-programming-rules.md#big-types-first) references this. C++ compilers will optimize for you and often this creates a binary interface that is not useable across different compilers. If you compiled with the same exact version of the same compiler, it will often have an ABI that it adheres to.

## Conclusion
So in conclusion, this is the reason I moved all my engine code to C. C has a strict ABI for structs across all compilers and versions if they want to be part of the ISO. This makes it so that developers who use the engine don't have to be forced to use a specific compiler. This also makes it so that you can distribute a .dll/.so/.a instead of requiring the developer to compile all of the source code for your library/tool/engine.
