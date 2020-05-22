---
title: Writing A Ray Tracer using CUDA
description: How I wrote a ray tracer that took over 30 seconds on CPU and remade it in CUDA to render in ~20 milliseconds
tags: ray-tracer ray-tracing cuda nvidia gpu-programming gpgpu
image: https://i.imgur.com/GXtGeT3.png
---

**What took the CPU (1 thread) over 30 seconds to render, I was able to get CUDA to render in ~20 milliseconds.**

There are plenty of places on the internet to learn how to write a ray tracer, so that is exactly what I did, I found one online and learned about making a **lambert**, **metal**, and **glass** material ray tracer (with some configurable values). I had 1 problem with what I learned, the render took about 5 minutes and 5 seconds (on 1 thread) to generate a single 720x480 render. This is where I decided to learn GPU progrmaming and parallelize my code beyond a measly 8 threads. Something that is much more scarce to find online is GPU programming (GPGPU - general purpose gpu programming). I happen to have a pretty decent Nvidia card (GeForce GTX 1070) and so CUDA it was for me (though I also took a look at OpenCL).

## Ray Tracer Basic Concepts
TBD

## CPU program structure
TBD

## Quick and dirty GPU rundown
TBD

## GPU program structure
TBD

## Porting CPU Raytrace To GPU
TBD

## CUDA performance
There are a number of things to consider when it comes to writing performant code in Cuda. Without someone telling you about these rules, you are doomed to only learn through self experience; so hopefully I can give you a quick head start.

### Rule #1 - Memory Access
One of the #1 things that is going to destroy your program's performance is dynamic memory access. If you used `cudaMalloc` or the other variants to allocate memory to be used by your CUDA fragment, you've better ran out of constant, texture, or shared memory first. Constant memory is small (seems to be 65K for most people), you can find your available constant memory by using the info API and getting the value at runtime or by looking at your system info (image below).

![image](https://i.imgur.com/jou4rcr.png)

All this being said, it is called `constant` memory for a reason, it is cached and you are not to modify it. If your program needs to modify values that the CPU needs to access, then you should be using dynamic memory.

### Rule #2 - Beware of program branching
Where GPUs are extremely fast to run kernel code in parallel, they are awful at resolving code branching. Traditionally people think that if you start up 2 threads on a CPU you'll have a copy of the program running independantly on what seems like 2 different machines. Well we're going to flip that perception on it's head for parallel computation on a GPU. Imagine that each time you have a branch (an if statement) in your code and you have 32 warps (what you think of as threads) computing a kernel function. The moment you hit an if statement, let's say 20 take the `if` path and 12 take the `else` path. What actually happens is the 12 that took the `else` path (in this hypothetical) completely stall! That's right, they are sitting there doing nothing. Now when the 20 warps finish the `if` branch then the 12 warps that were stalled can now process the `else` case; you guessed it, while the other 20 warps stall! You see the GPUs SMs (streaming multi-processors) want to be executing the same instruction across all the warps at the same time. So get out your thinking caps and do whatever you can to reduce as much branching in your algorithm as much as possible!

### Rule #3 - Be aware of your hardware "warps"
When you first hear about "threads" in your GPU you might think, "oh cool, 65535 threads per block!". Well yes, you could do that, but your performance will most likely suffer from doing that. This is because what you think of as "threads" is probably better related to what are called "warps". Now you have way less warps than threads (think 32 or 64), so if you can hit that sweet spot of getting the exact amount of threads to match up to warps per block you'll be cranking out numbers really fast. I have done **many** tests and can tell you from experience, if you go over your warp size per block, you could very well take 2x+ longer time to execute your kernel. In my test I by blowing my warp size I went from 20ms to ray trace a 720p image to 53ms by going over my warp size per block (even by just a few threads).

### Rule #4 - More blocks != more performance
So you think, well because of Rule #3 I should just spread out across more and more blocks and not cram a bunch of threads per block. Theoretically you'd be right, however you only have a limited number of SMs (streaming multi-processors) in your GPU. Let's say you only have 15 SMs. Well in this case cramming more blocks into your grid will not do anything other than better distribute your warps, at the end of the day you still only have the same amount of processors to work with. To better understand your processor, you'll want to (1) look at your hardware specs info and (2) test out different ranges of threads, blocks, and grids.

## Please read this very useful documentation!
[Understanding the profiler](https://docs.nvidia.com/nsight-visual-studio-edition/2019.4/Nsight_Visual_Studio_Edition_User_Guide.htm#Profile_CUDA_Settings.htm%3FTocPath%3DAnalysis%2520Tools%7CCUDA%2520Experiments%7C_____0)
