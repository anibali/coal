require File.dirname(__FILE__) + "/spec_helper"

describe Coal do

# Tests to make sure that:
# 1. Code is parsed into the correct tree
# 2. Tree evaluates to correct int32 result with both the Ruby and LibJIT
#    translators

coal_examples :bool, [

  "return(true && false)",
  [[:ret, [:and, true, false]]],
  false,
  
  "return(true && true)",
  [[:ret, [:and, true, true]]],
  true,
  
  "return(true ^^ false)",
  [[:ret, [:xor, true, false]]],
  true,
  
  "return(true ^^ true)",
  [[:ret, [:xor, true, true]]],
  false,
  
  "return(true || false)",
  [[:ret, [:or, true, false]]],
  true,
  
  "return(true || true)",
  [[:ret, [:or, true, true]]],
  true,
  
  "return(!true)",
  [[:ret, [:not, true]]],
  false,
  
  "return(!false)",
  [[:ret, [:not, false]]],
  true,

]

end

