Coal
====

* http://github.com/dismaldenizen/coal
* http://rdoc.info/github/dismaldenizen/coal

Warning
-------

Coal is still under heavy development. Use at own risk!

Synopsis
--------

Ruby is an awesome programming language that makes coding a real pleasure.
Unfortunately, it isn't great for writing high performance functions. Wouldn't
it be nice to create encapsulated functions in a super-fast, low-level
language without worrying about compilation and portability?

Coal is a language which integrates with Ruby programs. It uses JIT compilation 
for speedy execution, but will fall back to plain Ruby if need be. The idea is
that library developers can write methods using Coal, and users won't even
know that anything but Ruby is involved. Here is an example:

    !!!rb
    require 'coal'
    
    module AwesomeMath
      include Coal::Power
        
      defc 'self.factorial', [:uint32], :uint64, <<-'end'
        uint32 n = arg(0)
        uint64 factorial = 1
        uint32 i = 1
    
        while(i <= n)
        {
          factorial *= i
          i += 1
        }
    
        return(factorial)
      end
    end
    
    AwesomeMath.factorial(5) #=> 120

You'll notice that Coal is everything that Ruby isn't: it's dirty, static and
fast. It may not be pretty, but it can be very useful.

More examples
-------------

Take a look at the 'spec' folder for various snippets of Coal code and their
expected results.

Features
--------

* Super-fast JIT compilation via LibJIT
* No need for any native compilation by you or your users

TODO
----

* Finish a basic implementation!
* Cache translated code for quicker startup
* Bring Ruby translator up to scratch

