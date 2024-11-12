---
title: On C++
description: My views on C++ and how developers should look at the langauge 
tags: c, c programming, c coding, c++, c plus plus, c++ programming
date: November 12, 2024
---

On C++,

Today, its quite popular to express disliking of C++. Many individuals I hold in high regard maintain compelling arguments to the matter. I myself have made similar complaints about the pitfalls of the language. One could see a direct line between Golang, Rust, Zig, Odin, and others to try and find a middle ground between C and C++. All of which have far surpassed the mark in my opinion.

It is worth understanding, that the middle ground that most desire can be found within the bounds of C++. Though, the bounds of C++ are so expansive this idea leaves little effort to contrive. Indeed, all other aforementioned languages share this middle ground, but not quite as directly as C++.

The primary contention of C++ could be mitigated with programmer discipline. Artfully choosing when a derivation from one type to another should occur, that being when the derived identity is to have a single occurrence, for example; takes more effort than in C. Some well intentioned features can, and arguably should, be abandoned altogether, such as operator overloading. Virtual tables created from virtual functions dismantle the convenience of serialization of structures, though often structures contain troublesome pointers which present similar problems.

Other issues with derivation include potential hidden memory fragmentation, and thus cache-misses, from types required to be held as pointers to the base type. This is not exclusive to C++ as any journeyman C developer can attest to. This is a fragment of the complaints, and we've not ventured into compile time issues. The complexity of compile-time checking, templates, constexpr, header duplication, and so forth dramatically decreases developer productivity. Any C++ developer working on a large venture in Unreal Engine will have many tales of entire days lost to compiling and producing builds.

As the popular opinion goes, C++ gives you a foot gun.

That being said, I don't believe abandoning it's offerings is always the wise choice. The tools provided, with extreme discipline are valuable for us C developers. I don't believe C++ is a young man's language, young developers should spend vast quantities of time in many other languages, most notably C, to understand the discipline required for a language such as C++. That is not to say that C++ is a superior offering to C, as it isn't, and any argument over the matter is best left to the quibbles of those who have such time to indulge in it.

One should always be skeptical of "magic" code, things like exception capture and its stack unwinding, destructors, operator overloading, inheritance and virtual functions, and a host of wizardry that can be found within the STL. Remember, you don't pay for what you don't use, so try to use as little as possible.
