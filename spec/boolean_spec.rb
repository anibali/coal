($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe Coal do

# Tests to make sure that:
# 1. Code is parsed into the correct tree
# 2. Tree evaluates to correct int32 result with both the Ruby and LibJIT
#    translators

tests = [
  "return(!true)",
  [[:ret, [:not, true]]],
  false,
  
  "return(!false)",
  [[:ret, [:not, false]]],
  true,
]

[true, true, true, false, false, true, false, false].each_slice(2) do |a, b|
  tests << "return(#{a} && #{b})"
  tests << [[:ret, [:and, a, b]]]
  tests << (a && b)
  
  tests << "return(#{a} ^^ #{b})"
  tests << [[:ret, [:xor, a, b]]]
  tests << (a ^ b)
  
  tests << "return(#{a} || #{b})"
  tests << [[:ret, [:or, a, b]]]
  tests << (a || b)
end

coal_examples :bool, tests

end

