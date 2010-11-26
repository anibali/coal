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
seemlessly drop into low-level C code when creating certain
aspects of their software. The nasty pointer-riddled code can be
encapsulated in a function and need never be a problem for
other developers or users.

Don't believe that Coal is fast? Here are the results of running benchmarks on
a 3.4 GHz quad core system (obviously, the less time the better):

<div style="padding: 32px 32px 32px 48px;">
<table id="benchmark_results" style="display: none;">
	<caption>Benchmark results</caption>
	<thead>
		<tr>
			<td></td>
			<th scope="col">1000th prime</th>
			<th scope="col">100th prime</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<th scope="row">Ruby</th>
			<td>1.96</td>
			<td>0.44</td>
		</tr>
		<tr>
			<th scope="row">Coal</th>
			<td>0.08</td>
			<td>0.02</td>
		</tr>
	</tbody>
</table>
</div>

<script>
$("#benchmark_results").visualize({
  width: "300px",
  height: "200px",
  colors: ['#8C3939','#333333']
});
</script>

The Ruby code:

{% highlight ruby %}
def prime(n)
  return 2 if n == 1
  
  x = 1
  m = 1
  
  while(m < n)
    x += 1
    y = 2
    while(x % y != 0)
      m += 1 if (y += 1) / x == 1
    end
  end
  
  return x
end
{% endhighlight %}

The C code:

{% highlight c %}
int prime(int n)
{
  if(n == 1) return 2;
  
  int x = 1;
  int y;
  int m = 1;
  
  while(m < n)
  {
    ++x;
    y = 2;
    while(x % y)
    {
      if(++y / x) ++m;
    }
  }
  
  return x;
}
{% endhighlight %}

How does it work?
-----------------

Coal interfaces with LibJIT binaries via FFI to generate machine code at runtime.

