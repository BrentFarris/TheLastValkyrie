---
title: Writing A Ray Tracer using CUDA
description: Just an about page you can completely ignore
tags: ray-tracer ray-tracing cuda nvidia gpu-programming gpgpu
image: https://user-images.githubusercontent.com/1002223/80856091-b0f32b80-8bfb-11ea-9730-b17b53f2e94b.png
---

There are plenty of places on the internet to learn how to write a ray tracer, so that is exactly what I did, I found one online and learned about making a **lambert**, **metal**, and **glass** material ray tracer (with some configurable values). I had 1 problem with what I learned, the render took about 5 minutes and 5 seconds (on 1 thread) to generate a single 720x480 render. This is where I decided to learn GPU progrmaming and parallelize my code beyond a measly 8 threads. Something that is much more scarce to find online is GPU programming (GPGPU - general purpose gpu programming). I happen to have a pretty decent Nvidia card (GeForce GTX 1070) and so CUDA it was for me (though I also took a look at OpenCL).

