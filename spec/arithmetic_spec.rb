($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe Coal do

# Tests to make sure that:
# 1. Code is parsed into the correct tree
# 2. Tree evaluates to correct int32 result with both the Ruby and LibJIT
#    translators

coal_examples [

# Code                    Tree                                  Result
  "return( 7*2)",         [[:ret, [:mul, 7, 2]]],               14,
  "return(10+ 6)",        [[:ret, [:add, 10, 6]]],              16,
  "return(22 - 12)",      [[:ret, [:sub, 22, 12]]],             10,
  "return(64 /2)",        [[:ret, [:div, 64, 2]]],              32,
  "return(5 % 3)",        [[:ret, [:mod, 5, 3]]],               2,
  "return(3**3)",         [[:ret, [:pow, 3, 3]]],               27,
  "return(-31)",          [[:ret, [:neg, 31]]],                 -31,
  "return(-(2-6))",       [[:ret, [:neg, [:sub, 2, 6]]]],       4,
  "return(2 * 3 * 4)",    [[:ret, [:mul, [:mul, 2, 3], 4]]],    24,
  "return(2 - 3 + 4)",    [[:ret, [:add, [:sub, 2, 3], 4]]],    3,
  "return(1 << 6)",       [[:ret, [:lshift, 1, 6]]],            64,
  "return(106 & 63)",     [[:ret, [:bit_and, 106, 63]]],        42,
  "return(21 ^ 63)",      [[:ret, [:bit_xor, 21, 63]]],         42,
  "return(40 | 10)",      [[:ret, [:bit_or, 40, 10]]],          42,
  
  "uint8 x = 0 ; x = ~x ; return(x)",
  [[:decl, 'uint8', 'x', 0], [:sto, 'x', [:bit_neg, 'x']], [:ret, 'x']],
  255,

]

end

