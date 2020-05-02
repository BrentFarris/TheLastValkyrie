---
title: Writing A Ray Tracer using CUDA
description: How I wrote a ray tracer that took over 5 minutes on CPU and remade it in CUDA to render in 1 second
tags: ray-tracer ray-tracing cuda nvidia gpu-programming gpgpu
image: https://raw.githubusercontent.com/BrentFarris/TheLastValkyrie/master/docs/images/Ray%20Tracing%20With%20Cuda/cpu-trace.png?token=AAHUV36LBBOOK65JNZ54GE26W4BYG
---

**What took the CPU (1 thread) over 5 minutes to render, I was able to get CUDA to render in just over 1 second.**

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
**Rule #1**: One of the #1 things that is going to destroy your program's performance is dynamic memory access. If you used `cudaMalloc` or the other variants to allocate memory to be used by your CUDA fragment, you've better ran out of constant, texture, or shared memory first. Constant memory is small (seems to be 65K for most people), you can find your available constant memory by using the info API and getting the value at runtime or by looking at your system info (image below).

![image](https://raw.githubusercontent.com/BrentFarris/TheLastValkyrie/master/docs/images/Ray%20Tracing%20With%20Cuda/gpu-const-mem-size.png?token=AAHUV3ZXRB2WWS5E3ZEIAXK6W4B2O)

All this being said, it is called `constant` memory for a reason, it is cached and you are not to modify it. If your program needs to modify values that the CPU needs to access, then you should be using dynamic memory.

**Rule #2**: Beware of program branching.
