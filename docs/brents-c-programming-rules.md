TBD
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

Now let's look at another exmaple using a `char*` to represent a string function. Here we have a function that takes a string and clones it (wrong way):
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
## No need for typedef
## Don't over-complicate strings
## Use utf8 strings
## Don't use char for memory array, use uint8_t
## Use standard bool
## Don't use static/global variables
## Prefer inline over macro
## Test your functions
## Write functions to do one thing
## Don't write systems, write modular pieces (think UNIX)
## Warnings are errors
	- Enable /Wall
	- Build 3rd party code into a lib, many libs have warnings and we can't have that with /wall and warnings as errors
## If there is a standard, use it
