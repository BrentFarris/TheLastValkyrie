# x64 Assembly
Something that I have gotten really into recently is x64 Assembly programming. So, I thought I would jot down some of the notes that I've collected from developing in the language. I am using the **MASM** assembler in a **Visual Studio** environment as their memory, registers, and debugging tools work well for my needs.

**JMP**
- [Microsoft procedure calling conventions](#microsoft-procedure-calling-conventions)
- [Microsoft procedure call weirdness](#microsoft-procedure-call-weirdness)
- [Setting up a x64 only project in Visual Studio](#setting-up-a-x64-only-project-in-visual-studio)
- [Code examples](#code-examples)

## Microsoft procedure calling conventions
First of all, [this document](https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention?view=vs-2019) is very helpful for understanding Microsoft calling conventions.

In short, Microsoft uses ECX, EDX, R8, and R9 as the first four arguments for a procedure call and any remaining arguments should be pushed onto the stack. Below is a sample from their docs:
```c++
func1(int a, int b, int c, int d, int e);
// a in RCX, b in RDX, c in R8, d in R9, e pushed on stack
```
The following is the calling convention for using floats as arguments to functions. Note, if you mix input arguments, you should still be using the order described in the samples. That is to say if you have an `int` as the first argument and a `float` as the second argument, you should use `RCX, XMM1` respectively.
```c++
func2(float a, double b, float c, double d, float e);
// a in XMM0, b in XMM1, c in XMM2, d in XMM3, e pushed on stack
```
Lastly, when calling a procedure, the return value for the call (if any) will be put into RAX.

## Microsoft procedure call weirdness
Something that I haven't found in the Microsoft documentation or anywhere else is an answer to the weirdness that I had when calling procedures like `HeapAlloc` and `HeapFree`. Calling these procedures and then doing a `ret` would cause a memory access error. These procedures would make use of 32 bytes of the stack but it would be the current stack. What this would do is mess up the return address that was set onto the stack by the previous `call` instruction, in my case it changed the address to the value `03h` for some reason. Since I'm not experienced enough to understand why this is yet, the solution I found was to move the stack index before and after calling them.
```asm
sub rsp, 32		; The call to HeapAlloc uses 32 bytes on the stack
call HeapAlloc
add rsp, 32		; Return the stack pointer to original location
;...
sub rsp, 32		; The call to HeapAlloc uses 32 bytes on the stack
call HeapAlloc
add rsp, 32		; Return the stack pointer to original location
```

## Setting up a x64 only project in Visual Studio
You will need to create a C++ project as you normally would. Though you are selecting this to be a C++ project, we will not be creating any C/C++ file types, we will only be creating `.asm` files.

![create project](https://i.imgur.com/bSTEXxK.png)

Make sure to give your project a suitable name during the configuration step.

![configure project](https://i.imgur.com/uANUd1m.png)

Something that I like to do is get rid of the normal Visual Studio solution explorer folders and just show all files so that I can setup the directories how I want to set them up.

![show all files in visual studio](https://i.imgur.com/xEovGhd.png)

Next we need to enable the MASM assembler in the build customizations

![build customizations](https://i.imgur.com/PmhGv79.png)

![masm assembler build customization](https://i.imgur.com/pHpopaB.png)

Now lets create a `src/main.asm` file to make sure things are setup correctly. When you create the file, right click on it and go to the file's properties.

![asm file properties](https://i.imgur.com/KaZtEgj.png)

You should see that the file type is set to **Microsoft Macro Assembler**.

![asm file item type](https://i.imgur.com/QhMLYlf.png)

Next, you need to set the label that will serve as your entry point in the Visual Studio project properties. To keep things simple, we will name our entry point label `main`. So to set this up you need to go to project properties.

![project properties](https://i.imgur.com/zVPiaed.png)

Then you need to go to the Linker->Advanced settings and set the **Entry Point** value to `main`. *Note: Make sure that you are in x64 mode and not x86*.

![entry point label setting](https://i.imgur.com/0ZYcoG4.png)

Now that you have done all that setup, turn your debugger to x64 mode (through the dropdown in Visual Studio next to the debug button) and test things out.

![assembly running](https://i.imgur.com/cak8imM.png)

## Code examples
What better way to learn something than through some code examples. Below are some ASCII string query routines that I have written in x64. *Note: these routines are slower, but it works good for example sake. I use a faster versions of these routine in my personal code that account for cache lines and heap access.*

**strlen** - Get the length of a string. 
```asm
;****************************************;
; RAX = The string to get the length for ;
; Returns length of string in RAX        ;
;****************************************;
strleninline PROC
	push rbx				; Save the state of rbx since we are going to use bl
	push rcx				; Save the state of rcx since we are going to use bl
	mov rcx, rax			; Create a copy of rax to diff at end
strleninline_loop:
	mov bl, [rax]			; Copy the ascii letter at the rax address into bl
	inc rax					; Go to the next ascii letter at rax
	cmp bl, 0				; Check to see if the character is a \0
	jnz strleninline_loop	; If not \0 then continue through the loop
	dec rax					; We don't want to count \0 as part of the length
	sub rax, rcx			; Put the length in rax by subtracting address locations
	pop rcx					; Restore the state of rcx
	pop rbx					; Restore the state of rbx
	ret
strleninline ENDP
```

**strindexof** - Get the index of a string (needle) within another string (haystack)
```asm
;*******************************************************;
; RAX = Needle string (string should be in start)       ;
; RBX = Haystack string (string to check within)        ;
; Returns 0 in RAX if false, anything otherwise is true ;
;*******************************************************;
strstartswith PROC
	push rcx				; Save the state of rcx
	push rdx				; Save the state of rdx
	mov rdx, rax			; Copy rax to rdx since we are going to call strlen routine
	call strlen
	mov rcx, rax			; Move the len of the needle string into our counter register
	mov rax, 0				; Set the return to false
strstartswith_loop:
	mov r8b, [rbx]			; Get the character from haystack string
	cmp r8b, [rdx]			; Compare character from the needle string
	jnz strstartswith_exit
	inc rbx					; Move to the next character in haystack string
	inc rdx					; Move to the next character in needle string
	loop strstartswith_loop
	mov rax, 1				; The string starts with match!
strstartswith_exit:
	pop rdx					; Restore the state of rdx
	pop rcx					; Restore the state of rcx
	ret
strstartswith ENDP
```

**strstartswith** - Determines if a string (haystack) starts with another string (needle)
```asm
;*******************************************************;
; RAX = Haystack string (string to check within)        ;
; RBX = Needle string (string should be in start)       ;
; Returns -1 in RAX if not found, otherwise RAX = index ;
;*******************************************************;
strindexof PROC public
	push rcx				; Save the state of rcx
	push rdx				; Save the state of rdx
	push rax				; Save the haystack to the stack
	push rbx				; Save the needle to the stack
	mov rdx, rax			; Copy rax to rdx since we are going to call strlen routine
	call strlen
	mov rcx, rax			; Move the len of the haystack into our counter register
	mov rax, rdx			; Set the found address to the starting address
	dec rax					; Make it so that sub rax, haystack will be -1
	cmp rcx, 0				; Check to make sure we are not looping through a 0 string
	jz strindexof_exit_loop
strindexof_loop:
	mov r8b, [rdx]			; Get the character from haystack string
	cmp r8b, [rbx]			; Compare character from the needle string
	jne strindexof_notfound
	mov r8, [rsp+8]			; Get the haystack from the stack without popping
	cmp rax, r8				; See if rax has already been set, otherwise set it
	jge strindexof_check
	mov rax, rdx			; rax is -1 from haystack address, so it needs to be set
strindexof_check:
	inc rbx					; Go to the next letter in the needle
	mov r8b, [rbx]			; Get the character code for the next letter in needle
	cmp r8b, 0				; If it is the 0 string terminator, then we need to end
	jz strindexof_exit_loop
	jmp strindexof_continue
strindexof_notfound:
	pop rbx					; Reset the needle to it's starting address
	pop rax					; Reset rax to haystack starting address
	push rax				; Put the value back onto the stack for the haystack
	push rbx				; Push needle starting address back onto stack
	dec rax					; Make it so that sub rax, haystack will be -1
strindexof_continue:
	inc rdx					; Move to the next character in haystack string
	loop strindexof_loop
strindexof_exit_loop:
	pop rbx					; Remove the stored neele address as it isn't needed
	pop rdx					; Reset the haystack pointer to beginning of string
	sub rax, rdx			; Get the address difference of the needle and haystack
strindexof_exit:
	pop rdx					; Restore the state of rdx
	pop rcx					; Restore the state of rcx
	ret
strindexof ENDP
```
