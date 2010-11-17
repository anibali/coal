Coal
====

TODO: Introduction

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

