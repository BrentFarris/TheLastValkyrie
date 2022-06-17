---
title: Writing A Ray Tracer using CUDA
description: How I wrote a ray tracer that took over 30 seconds on CPU and remade it in CUDA to render in ~20 milliseconds
tags: ray tracer, ray tracing, cuda, nvidia, gpu programming, gpgpu
image: https://i.imgur.com/GXtGeT3.png
date: 05/15/2020
---

***What took the CPU (1 thread) over 30 seconds to render, I was able to get CUDA to render in ~20 milliseconds.***

There are plenty of places on the internet to learn how to write a ray tracer, so that is exactly what I did, I found one online and learned about making a **lambert**, **metal**, and **glass** material ray tracer (with some configurable values). I had 1 problem with what I learned, the render took about 5 minutes and 5 seconds (on 1 thread) to generate a single 720x480 render. This is where I decided to learn GPU progrmaming and parallelize my code beyond a measly 8 threads. Something that is much more scarce to find online is GPU programming (GPGPU - general purpose gpu programming). I happen to have a pretty decent Nvidia card (GeForce GTX 1070) and so CUDA it was for me (though I also took a look at OpenCL).

**JMP**
- [Ray Tracer Basic Concepts](#ray-tracer-basic-concepts)
- [CPU program structure](#cpu-program-structure)
- [Quick and dirty GPU rundown](#quick-and-dirty-gpu-rundown)
- [Porting CPU Raytrace To GPU](#porting-cpu-raytrace-to-gpu)
- [CUDA performance](#cuda-performance)
  - [Rule #1 - Memory Access](#rule-1---memory-access)
  - [Rule #2 - Beware of program branching](#rule-2---beware-of-program-branching)
  - [Rule #3 - Be aware of your hardware "warps"](#rule-3---be-aware-of-your-hardware-warps)
  - [Rule #4 - More blocks != more performance](#rule-4---more-blocks--more-performance)
- [Please read this very useful documentation!](#please-read-this-very-useful-documentation)

## Ray Tracer Basic Concepts
*TBD (I'll be back to add this part in, I wanted to write out the important bits first)*

![image](https://i.imgur.com/GXtGeT3.png)

## CPU program structure
*TBD (I'll be back to add this part in, I wanted to write out the important bits first)*

## Quick and dirty GPU rundown
- **Kernel** - A program to be copied (distributed) and ran across the GPU to run
- **__host__** - A keyword to tell the compiler that the following function is to be built into the CPU-bound software
- **__device__** - A keyword to tell the compiler that the following function is to be built into the GPU-bound software
- **__constant__** - A keyword used to define a handle to constant memory on the GPU
- **Threads** - A unit of work
- **Blocks** - A container for many threads in x, y, and z dimensions
- **Grids** - A container for many blocks in x, y, and z dimensions
- **Warps** - Think of this as what you consider a thread, it can be associated with the execution of instructions
- **Streaming Multiprocessor(s)** - Fancy word for the physical compute device(s) processing your instructions
- **Dynamic Memory** - Memory that can be dynamically allocated, changed, and accessed
- **Shared Memory** - A fixed amount of memory (you specify) that is shared between all threads in a block
- **Constant Memroy** - A fixed size area of memory where you can read values from but not change them after written
- **Texture Memory** - TBD (I've not used this extensively yet but is similar to constant memory)

**Note:** You can get the x, y, and z, index of your thread, block, and grid. This is how you are able to control the outcome of the program. Imagine you have 1 grid of blocks in a 128 x 128 x 1 (x, y, z) layout with 1 thread in each block. You can imagine that each x and y coordinate of the block can be thought of as an x and y coordinate for a pixel in an image. So this makes it easy to compute each pixel in a 128x128 image very efficiently while making it easier to think of each thread/block as a single pixel. **Remember** you can have an x, y, z for a thread, an x, y, z for a block, and an x, y, z for a grid; that's like 6 dimensions to work with! Perhaps you want to do something other than images, you want to do an AI neural network? Seems like a great way to utilize those dimensions to me! Below is some helper code for you to get the thread index, block index, and grid index.
```c
int threadsPerBlock = blockDim.x * blockDim.y * blockDim.z;
int blocksPerGrid = gridDim.x * gridDim.y * gridDim.z;
int threadPositionInBlock = threadIdx.x +
	blockDim.x * threadIdx.y +
	blockDim.x * blockDim.y * threadIdx.z;
int blockPosInGrid = blockIdx.x +
	gridDim.x * blockIdx.y +
	gridDim.x * gridDim.y * blockIdx.z;
```

## Porting CPU Raytrace To GPU
Being that I wrote my prorgram code in C and not C++ I can only speak of the experience of porting C code over to Cuda. Honestly it was extremely easy because of the great support for C syntax compatability in Cuda. The primary thing I had to do was specify if each function was to run on the host (regular C software code) via the `__host__` prefix keyword and/or if it ran on the device (gpu code) via the `__device__` function prefix keyword. One absolutely annoying thing I didn't fully investigete in my port was why I couldn't have separate C files play well with my compiler. I was less interested in the symantics of separate files and spending hours on that, so I opted to write all the functions used in Cuda directly into the single `kernel.cu` file which allowed me to focus on the problem at hand. The last part after saying which functions go where was to call the `func<<<grid, block>>>(arg1, arg2, arg3);` function to run my code on the GPU. Of course there were a couple more things to worry about such as allocating memory on in cuda via `cudaMalloc` and getting my cpu data over through `cudaMemcpy`. One extra performance addition was to put all my spheres into constant memory by declaring
`__constant__ struct Sphere cuda_Spheres[500];` and then `cudaMemcpyToSymbol(cuda_Spheres, spheres, sphereCount * sizeof(struct Sphere), 0, cudaMemcpyHostToDevice);`
to copy the spheres into constant memory (this made a huge performance increase over dynamic memory).

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

[Writing a raytracer 3 books](https://raytracing.github.io/)
