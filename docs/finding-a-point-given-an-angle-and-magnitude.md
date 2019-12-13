---
title: Finding a point given an angle and magnitude
description: I found myself asking the question "how do I find a point given an angle and magnitude" once upon a time, so I wrote it down.
tags: angle magnitude math point point-from-angle
---

A few years back I was asking the question "how do I find a point given an angle and magnitude" when I was programming something. I wrote down the study I did back then and I thought I would put it up here as an easy place for review.

Sometimes you have an issue where you are trying to find a point that is not vertical or horizontal from another point, instead you only know the length and the angle in degrees that the point should be in from your current position. The following image shows 2 points plotted on a graph (2, 2) and (6, 5). Using the Pythagorean Theorem, we know that the hypotenuse is 5.

![figure finding-a-point-given-an-angle-and-magnitude-1](https://i.imgur.com/xF22sYA.jpg)

Now imagine that we would want to find the other 2 points that make up a square using these 2 points. We know that a square has the same length on all sides, and we found the length of one side using a<sup>2</sup>+b<sup>2</sup>=c<sup>2</sup>, which means all other sides must have a length of 5. First off, we know that each corner of a square is 90° from Geometry (angles of all corners add up to 360° in any quad, since a square is symmetrical, we do 360&frasl;4). What we currently don’t know is the angle of the right triangle formed by a, b, and the point where they intersect. To get this angle we will use Trigonometry. For the sake of clarity, let’s first pull in an image of this imaginary right triangle and its side lengths.

![figure finding-a-point-given-an-angle-and-magnitude-2](https://i.imgur.com/2zK1nKE.jpg)

At this point we want to find the angle at the top right of the triangle so that we can add it to the 90° that we discussed. We have the lengths for all the sides, so we can pick any equation we want from SOH-CAH-TOA. I will pick SOH to find the angle [sin(opposite ÷ hypotenuse)] so the equation will become the following.
<div align="center">sin<sup>-1</sup>(1&frasl;4)=53.13°</div>
Now that we have the angle of the top right corner of the triangle, we will add that to the 90° of the bottom corner of the square that is adjacent to this angle.
<div align="center">Θ=90°+53.13°=143.13°</div>
Note that since this is a square, we only need to find 1 point, then use that delta to plot the other point. Below is the formula required to calculate this point. The *magnitude* is 5 and Θ is the angle in degrees we’ve calculated (in this case 143.13°).
<div align="center">x = magnitude × cosΘ=5 × cos(143.13) ≈ 5(-0.79) ≈ -3.99</div>
<div align="center">y = magnitude × sinΘ=5 × sin(143.13) ≈ 5 × 0.6 ≈ 3</div>
Now if you were to plot out these points on our given diagram you will obviously not get a square. There is one more thing we need to do and that is to add the offset of the x and y of our points to these values. So, since we are dealing with the top right point, we will need to add 6 and 5 respectively.
<div align="center">p = &lt;x+6, y+5&gt; = &lt;2.01, 8&gt;</div>
![figure finding-a-point-given-an-angle-and-magnitude-3](https://i.imgur.com/OYA81n4.jpg)

From this point you can do one of 2 things to find the other point of the square. One being you perform the same actions we’ve done up to this point except for the bottom left point of the triangle, or you can simply use the delta between the two points of the triangle that make up the edge of the square.
<div align="center">x = 2.01 - 4 = - 2.01</div>
![figure finding-a-point-given-an-angle-and-magnitude-4](https://i.imgur.com/7YZhHlk.jpg)

The previous image is the completed square which we were able to create from just two plotted points. As this section is about finding the point projected from an angle given a desired angle, this can be used for almost anything involving angles and finding points based on that because the real magic of this is being able to project in a direction based on a specific angle. Though we created a square we can create other shapes using this logic or even just project and plot any number of positions based on angles.
