require 'spec_helper'

describe Coal do

# Tests to make sure that:
# 1. Code is parsed into the correct tree
# 2. Tree evaluates to correct int32 result with both the Ruby and LibJIT
#    translators

coal_examples [

  "int8 i = 0 ; while(i < 10) { i += 1 }; return(i)",
  [[:decl, 'int8', 'i', 0],
  [:while, [:lt, 'i', 10],
    [[:sto, 'i', [:add, 'i', 1]]]],
  [:ret, 'i']],
  10,
  
  "int8 i = 0 ; until(i == 10) { i += 1 }; return(i)",
  [[:decl, 'int8', 'i', 0],
  [:until, [:eq, 'i', 10],
    [[:sto, 'i', [:add, 'i', 1]]]],
  [:ret, 'i']],
  10,
  
  "int8 i = 0 ; while(true) { i += 10 ; break }; return(i)",
  [[:decl, 'int8', 'i', 0],
  [:while, true,
    [[:sto, 'i', [:add, 'i', 10]],
     [:break]]],
  [:ret, 'i']],
  10,

]

end

