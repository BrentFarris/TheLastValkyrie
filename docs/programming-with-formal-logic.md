---
title: Programming with Formal Logic
description: For those who love math and love programming, it would be nice to join formal logic and code more often, here I explore that idea.
tags: programming, code, formal logic, math, mathematics
date: July 26, 2024
---

For those who have never coded before, but have done formal logic, you will probably be able to work out the following. For those who have coded and never invested much time into formal logic before, the following probably looks like Greek to you.
```
∀x ∈ ℤ, ∀n ∈ ℤ+ ∪{0}, (n = 0 ⇒ undefined) ∧ (n ≠ 0 ⇒ ∃y ∈ {0..n} (y = (x mod n + n) mod n))
```

The reverse is true for the following, but they are both doing the same thing.
```c
int wrap_array_index(int n /* length */, int x /* index */) {
	return (n > 0) ? (((x % n) + n) % n) : -1;
}
```

The C code presented here is very explicit, it has a name, it is a function, this function takes 2 arguments which are signed integers, it does an if check to make sure that `n` (the length) is greater than 0, if so then it will return the calculation result of `x`, otherwise it returns an invalid result (`-1`).

In the formal logic case, the idea is much more abstract from the actual machine implementation, though we see some similarities in the concepts. We say that `x` is an integer, we say that `n` is a positive integer from `0` to infinity, we say that if `n` is equal to 0, then it is undefined. We then use a conjunction (and) to say that if `n` is not 0 that implies then the result `y` is a number between `0` and `n` such that the expression `(x mod n + n) mod n)` evaluates the resulting `y` value.

So what is all of this doing in plain English? Well, we take some number (`x`) and we are wanting to wrap it within the bounds of 0 to some maximum integer value `n`. So if our max number was 5, then we want x to wrap in order to be one of the possible values {0, 1, 2, 3, 4}. That is to say, if `x`=2, then the result should be 2, if `x`=5, then the result should be 0, and if `x`=6, then the result should be 1. Also, if we input a negative number, it should wrap in reverse; so, `x`=-1 should be 4, `x`=-2 should be 3, `x`=-5 should be 0, and so on.

Of course, this is such a simple and common example of code to be doing a full formal logic specification on. We'd waste many, many hours writing specs if we were to work out one for every function in our codebase. However, it is fun to play around with formal logic in this way and work out what it would be for various functions. In fact, the goal should be to become fluent in the mathematics to write the larger ideas before you begin coding as to make sure you understand them. You can then run the models in a computer to verify the correctness of your design even before you start writing out code. Often, if you begin coding before you design, you will wind up having to re-iterate on that first implementation over and over, but later you are bound by so many other constraints that you may never be happy. Like Leslie Lamport says, (paraphrasing here) "there is a difference between coders and programmers, coders are to typists as programmers are to storytellers". Any monkey can code and make code performant, but it takes rigorous logical dicipline to create beautiful algorithms.

Just remember, your first idea is your worst idea.
