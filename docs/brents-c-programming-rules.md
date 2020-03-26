---
title: Brent's C Programming Rules
description: A bunch of tips and rules I've created for myself for developing programs in the C programming language 
tags: c c-programming c-coding c-rules rules programming-rules tips
---

Below are some rules that I have developed over a long period of time writing C programs. C is my favorite language and I love the freedom and exploration it allows me. I also love that it is so close to Assembly and I love writing assembly for much of the same reasons!

## Pure encapsulation
One of the great things about C is that it allows for "pure encapsulation". What this means is that you can explain all the intent of your code through the header file and the developer who uses your lib/code never has to look at the actual implementations of the code. Now to take this a step further, well all know that C supports the `struct` keyword to group data, and we can also make the members of a struct hidden completely from the developer using the library. For example, we could declare the following header and C files:

**vec3.h**
```c
#ifndef VEC3_H
#define VEC3_H

struct Vec3;

#endif
```

**vec3.c**
```c
#include "vec3.h"

struct Vec3 {
	float x;
	float y;
	float z;
};
```

As you can see in the above code sample, if you were just to have the header file, you would not know that this vector is implemented using 3 `floats`. This is very important for pure encapsulation. With this, you can completely control the behavior of the struct and it's contents using readable functions and not worry about the developer using the code directly mutating the members of your `struct`. Now that you've created pure encapsulation, you are able to feel safe knowing that developers can't new up the struct or abuse it's contents from anywhere other than through the code you've written in your `c` file.

## Memory ownership
With perfect encapsulation you are most of the way towards having good memory ownership. If you purely encapsulate your structs the only way for a developer to create a new instance of the struct would be through functions you create yourself. From this point you can create the `new` and `free` functions to manage the memory of your struct. Below is an example building upon the previous code sample.

**vec3.h**
```c
#ifndef VEC3_H
#define VEC3_H

struct Vec3;

struct Vec3* Vec3_new();
void Vec3_free(struct Vec3* vector);
void Vec3_print(struct Vec3* vector);

#endif
```

**vec3.c**
```c
#include "vec3.h"
#include <stdio.h>

struct Vec3 { /* ... */ };

struct Vec3* Vec3_new()
{
	struct Vec3* v = malloc(sizeof(struct Vec3));
	v->x = 0.0F;
	v->y = 0.0F;
	v->z = 0.0F;
	return v;
}

void Vec3_free(struct Vec3* vector)
{
	free(vector);
}

void Vec3_print(struct Vec3* vector)
{
	printf("<%f, %f, %f>", vector->x, vector->y, vector->z);
}
```

Above you can see that we encapsulate the creation, usage, and freeing of our `struct`. You would think, well with this, what else do we need to know about memory management? Well there is one more thing, more of a rule that you must follow more than anything else. **The thing that declares the memory is the thing that should free the memory**. We see this in action above, the `c` file that creates the memory in turn has a function for freeing the memory.

Now let's look at another example using a `char*` to represent a string function. Here we have a function that takes a string and clones it (wrong way):
```c
char* strclone(const char* str)
{
	size_t len = strlen(s) + 1;
	char* clone = malloc(len);
	memcpy(clone, str, len);
	return clone;
}
```

Now what is wrong with the memory management on this code? Answer, we are using `malloc` to create memory and then return the string. Let's take a look at the developer using this.
```c
char* str = "Hello Brent!\0";
char* cpy = strclone(str);
printf(cpy);
free(cpy);	// Allowed?
```

How is the developer suppose to know that they are to free the `char*`? For all they know the `strclone` uses some-sort of pooling functionality to re-use a pool of memory, we can't free that otherwise you risk seg-faulting. What is a better version of this?
```c
void strclone(const char* str, char** outCpy)
{
	size_t len = strlen(s) + 1;
	*outCpy = malloc(len);
	memcpy(outCpy, str, len);
}
```

Now with this version we make it explicit that the developer should manage their own object that they pass in. We use the hint name **out** as a prefix to the argument name to let them know memory will be allocated for this input variable. What does this look like to the developer?
```c
char* str = "Hello Brent!\0";
char* cpy;
strclone(str, &cpy);
printf(cpy);
free(cpy);
```

Looking at this version, the developer knows they are in charge of freeing the `cpy`, this is because they declare the variable in the first place, rather than being assigned from a function. If the developer follows our rule (**The thing that declares the memory is the thing that should free the memory**), they declared the variable/pointer so they should be the ones freeing it. Now I know you can argue all sorts of alternative setups for the return value, but the fact of the matter is that passing in a pointer to a pointer is much more clear of ownership.

## Avoid void*
One stigma people have against C is the use of `void*`, some think it is necessary, some use it to solve problems quickly through the path of least resistance, I say that there are **very few** cases when `void*` is acceptable and most of the time your current problem isn't it. Like `NULL`, `void*` is a lazy solution to a problem and causes all kinds of un-necessary runtime checking.

In most cases you should create a `struct` that explicitly defines what type is accepted or stored. The **biggest** advantage of this approach is that you put the compiler to work for you. There are all sorts of compile-time checks that will prevent you from doing something you shouldn't do. Also your IDE will be much more helpful when trying to navigate code as the IDE, nor the compiler, have any idea where a void* comes from or what it points to.

## No need for typedef
I'm with [Linus Torvolds](https://yarchive.net/comp/linux/typedefs.html) on this one, there is no need for the use of `typedef`. If you are afraid of typing a few extra letters to get things done, then why do you program? Typedef causes a lot of confusion and the naming schemes everyone comes up with to name these types are confusing at best. The worst thing is when a typedef hides a pointer, then even worse, people try to resolve that by putting the 3 letters "ptr" somewhere in the name, now you've ruined the whole not typing as much and made it completely confusing to read. I want to read C code and not have to parse people's random naming structure and hidden symbols. The silver lining of having to type `struct` a lot is that maybe that will encourage you to write less code?

## Don't over-complicate strings
If I want to live in the 2020 era of programming, that means I probably will wind up using more than one library to solve a problem. My new problem is that people think it is cute to typedef `char*` to some other name and only accept that name in their code. In the era of UTF8, that is completely un-necessary and makes me have to do a lot of senseless casting. If you want to encapsulate that you are using a string (so I don't know it) then cool, do that, but `typedef unsigned char* string` is not it. Please stick to the good ol' `char*` for strings.

## Use utf8 strings
Talking about strings, I'd like to point out that UTF-8 is fully compatible with ASCII, this means we don't need special functions for special characters or non English characters. All of our usual suspects of functions work on UTF-8 such as `fopen`! There are some helpful other things we can use thanks to compilers such as placing `u8` in front of an in-line string:
```c
char* utf8 = u8"Hello World!";
```

So in closing on the UTF-8 topic, please stop using `wchar_t`, `char16_t`, and all those other variants (except when you are forced to, due to 3rd party libraries). With that, I'll leave you with this helper function to get you started:
```c
int32_t u8strlen(const char* str)
{
	int32_t len = 0;
	unsigned char c = str[0];
	for (size_t i = 1; c != 0; len++)
	{
		if (c <= 127) i += 1;
		else if ((c & 0xE0) == 0xC0) i += 1;
		else if ((c & 0xF0) == 0xE0) i += 2;
		else if ((c & 0xF8) == 0xF0) i += 3;
		else
		{
			// Invalid string
			len = -1;
			break;
		}
		c = str[i];
	}
	return len;
}
```

## Don't use char for memory array, use uint8_t
In making code readable, you should only use `char*` or `unsigned char*` for strings (character arrays). If you want a block of bytes/memory pointer, then you should use `uint8_t*` where `uint8_t` is part of `stdint.h`. This makes the code much more readable where memory is represented as an unsighned 8-bit array of numbers (byte array). Now you can trust when you see a `char*` that it is referring to a UTF-8 (or ASCII) character array (text).

## Use standard bool
This one is easy:
```c
#include <stdbool.h>
```

Don't make defines for `false`, or `False`, or `FALSE` and it's true counterpart, please just use the standard library.

## Don't use static/global variables
So `static` functions are fine, they are great for breaking up functions to be readable. However, `static` variables are bad and almost always not needed. Remember that we are living in a world where our CPUs are not getting faster, they are just coming in larger quantites. Always think about threadability and controlling mutation. Even with a variable that is static to a `C` file and not global, you never know if someone is using threads to call your functions.

## Prefer inline over macro
Functions that are `inline` are much more readable, work better with your IDE code searching, and are much more readable when you get errors/warnings from the compiler. Some macros are great, don't ban them altogether, but do consider if you can do what you need through an inline function first.

## Test your functions
C is beautiful in the fact that you don't need unit test frameworks to fully test your code. It's lack of objects and hidden state make it even better for testing. If you create a function, make a test for it and give it your known test case arguments. Did I mention that I love not having to have a big complicated mocking library to fully test my code? If your function takes in a complicated struct for some reason, feel free to `define` out/in a test function for creating the struct you expect to be testing (do NOT comprimise perfect encapsulation for the sake of testing).

## Write functions to do one thing
Okay, this isn't a C only thing, but make sure your functions are not creating large call stacks. Feel free to use `static` local functions to break up the readability of large functions if you just can't seem to make functions do a single thing (for performance for example).

## Don't write systems, write modular pieces (think UNIX)
Don't write big complicated systems to cover many problems, even if things are losely related in many ways. It is better to break up your code into useful functional pieces and cleverly put them together to have complex behavior. The beauty of [Unix](https://youtu.be/tc4ROCJYbm0) is that you can get many things done through many small programs pieced together. In the same way, you should develop useful functions that can be pieced together through data.

## Warnings are errors
This one is a bit short. The idea is simple, warnings are errors.
1. Make sure **ALL** warnings are enabled (`/Wall`).
2. Make sure that you turn on **warnings as errors*

*Note:* If you copied some source code from the internet that you need and it is producing warnings, turn it into a lib and use the lib, **do not** comprimise your code for other people's un-checked code.

## If there is a standard, use it
This was touched on before with `stdbool.h`, but if there is a standard function or type, use it. Use things like `int32_t` over just `int` hoping that `int` will be 32-bit. If there is a standard function for doing something, don't re-invent the wheel. Wrapping standard functions such as `malloc` and `free` I would consider a necessary evil if you are creating tools to detect memory leaks and the like though.

## Use float epsilon for 0 checking
First of all, don't check a floating point value against `0` or `0.0F`. Instead check it against Epsilon like in the following:
```c
#include <float.h>

int main(void)
{
	float x = 1.0F;
	x -= 1.0F;
	if (fabsf(x) <= FLT_EPSILON)
	{
		// ... The value is basically 0, do some stuff
	}
	return 0;
}
```

Alternatively you can choose a fractionally small number like `0.0001F` to check against if that is your cup of tea as well. The reason is floating point precision errors (which you probably know or have heard of by now). I enjoy `FLT_EPSILON` because it is part of the `float.h` lib and a standard for everyone to use.

## More to come
There are inevitably more things I've forgotten about, but I've written this all in one sitting so this is good enough for now until I can update!
