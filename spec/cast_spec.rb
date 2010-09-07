require File.dirname(__FILE__) + "/spec_helper"

describe Coal do

# Tests to make sure that:
# 1. Code is parsed into the correct tree
# 2. Tree evaluates to correct int32 result with both the Ruby and LibJIT
#    translators

coal_examples [

# Code                        Tree                                    Result
  "return((uint8)532)",       [[:ret, [:cast, 532, 'uint8']]],        20,
  "return((uint8)-4)",        [[:ret, [:cast, [:neg, 4], 'uint8']]],  252,
  "return((int8)255)",        [[:ret, [:cast, 255, 'int8']]],         -1,
  "return((uint8)0xfffff)",   [[:ret, [:cast, 0xfffff, 'uint8']]],     255,

]

end

