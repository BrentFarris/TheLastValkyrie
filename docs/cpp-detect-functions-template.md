---
title: C++ Detect If A Class Has A Function Using Templates
description: Some C++ template magic to detect if a class actually has a function that matches a given signature without the need of putting it in the base class
tags: c++, c++ programming, detect function, class, templates
date: 07/03/2021
---

So something I wanted to test out recently is to see if I could detect if a function in a derived class existed, if it did, the function would be mapped to a function pointer, if it didn't a proxy function would be supplied. This is kind-of silly because you could have the base class have a blank base method, but I was more interested in testing out my C++ template-foo.

Below is the snippet of example code that I ended up with (working) and I'll explain the parts after.
```c++
// C-style struct with initialize function pointer
typedef struct SomeComponent SomeComponent;
struct SomeComponent {
	void(*_initialize)(SomeComponent* self, SomeType* someState);
	void(*_free)(SomeComponent* self);
};

//...

//SFINAE - https://en.wikipedia.org/wiki/Substitution_failure_is_not_an_error
template<typename T> class component_has_initialize {
	template<typename> static std::false_type test(...);
	template<typename U> static auto test(int)
	-> decltype(std::declval<U>().initialize(
		std::declval<SomeType*>()), std::true_type());
public:
	static constexpr bool value
		= std::is_same<decltype(test<T>(0)), std::true_type>::value;
};

template <typename T>
class OtherComponent : public SomeComponent {
	OtherComponent() {
		_free = [](auto s) { delete static_cast<T*>(s); };
		if constexpr (component_has_initialize<T>::value) {
			_initialize = [](auto s, auto e) {
				std::mem_fn(&T::initialize)(static_cast<T*>(s), e);
			};
		} else {
			_initialize = [](auto s, auto e) { /* do nothing */ };
		}
	}
}

```

The key to this code, as you may have figured from the comment, is SFINAE (Substitution failure is not an error). This allows us to derive from the `OtherComponent` type and either have a function named `initialize` or not. Notice that the arguments are defined as well (this is important to match the signature). If the derived class has an `initialize` funcction, then it will be assigned to the c-style struct's `_initialize` function pointer. If it does not have the function, then an empty function call will be assigned to the `_initialize` function pointer. Something you may note here is that we use `std::mem_fn` to convert the member function into a c-style function so that it can be called correctly when the `_initialize` C function pointer is called.

So what is going on here? We are creating a const expression `component_has_initialize` which takes in a type for it's template. We are then setting up 2 test funcgtions, one that takes an arbitrary number of arguments, and one that takes in explicitly the function signature we are looking for. Using `decltype` we can create the return type matched by the input expression. Using `std::declval` as we have an un-evaluated context which is matched against our argument types and class type. Lastly we use `std::true_type()` for the return of our test. From here we can setup our static `constexpr` named `value` which we can call within our template code to evaluate at compile time.

This took quite a bit of messing around to get right, but I thought it was a bit cool, even if not super useful!
