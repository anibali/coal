---
layout: default
---

**Coal** enables Ruby developers to easily incorporate sections of low-level C
code in their software. It makes use of
[LibJIT](http://dotgnu.org/libjit-doc/libjit_toc.html) to compile the code at
runtime, meaning that users do not need to have a compiler installed.

Why do I need this?
-------------------

Because it's fast!

Ruby is a great language which is easy to read and write, has a great
community and is backed by a vast collection of support libraries.
Unfortunately, Ruby tends to also be quite slow for certain operations.
Coal is an attempt to scratch this itch by allowing Ruby coders to
seemlessly drop into a lower-level language when creating certain
aspects of their software. The nasty pointer-riddled code can be
encapsulated in a function and need never be a problem for
other developers or users.

TODO: benchmark

How does it work?
-----------------

Coal interfaces with LibJIT binaries via FFI to generate machine code at runtime.

