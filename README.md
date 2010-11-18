Coal
====

Coal is an implementation of the C programming language within a Ruby
environment. Its goal is to enable Ruby developers to seamlessly integrate
sections of low-level code within their software in a simple and portable
manner. Coal's C implementation is based on the
[September 7, 2007 Committee Draft](http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1256.pdf),
but is not guaranteed to fully satisfy the specification.

Installing
----------

### From source

1. Install [libjit-ffi](https://github.com/dismaldenizen/libjit-ffi).
2. Download the source code for Coal and change into its root directory.
3. Install Bundler with `gem install bundler`.
4. Run `bundle install` to install dependencies.
5. Run `rake install` to build the Coal gem and install it.

Known issues
------------

* `long double` types are unsupported due to missing functionality in FFI

