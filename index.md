---
layout: default
---

**Coal** is a dirty, static and fast low-level programming
language which is fully integrated with Ruby. It makes use of
[LibJIT](http://dotgnu.org/libjit-doc/libjit_toc.html)
to compile the code at runtime, meaning that users do not need to have
a compiler installed.

Why do I need this?
-------------------

Because it's fast!

Ruby is a great language which is easy to read and write, has a great
community and is backed by a vast collection of support libraries.
Unfortunately, Ruby tends to also be quite slow for certain operations.
Coal is an attempt to scratch this itch by allowing Ruby coders to
seemlessly drop into a lower-level language when creating certain
aspects of their software. The nasty pointer-riddled code can be
encapsulated in a function or class and need never be a problem for
other developers or users.

Let's look at a silly example:

{% highlight ruby %}
module Test
  def self.do_work
    n = 13
    1000000.times { n *= 6 ; n /= 3 ; n /= 2 }
  end
end
{% endhighlight %}

On my AMD Athlon X2 3800 CPU, `Test.do_work` executes in 1.676331 seconds.

Now let's take a look at the equivalent Coal code:

{% highlight ruby %}
Coal.module 'Test' do
  function 'do_work', [], :void, <<-'end'
    intn n = 13
    intn i = 0
    while(i < 1000000)
    {
      n *= 6 ; n /= 3 ; n /= 2
      i += 1
    }
  end
end
{% endhighlight %}

On the same machine, `Cl::Test.do_work` takes only 0.114459 seconds. That's less
than a tenth of the execution time!

How does it work?
-----------------

Coal interfaces with LibJIT binaries via FFI to generate machine code at runtime.

