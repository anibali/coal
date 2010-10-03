require 'spec_helper'

describe Coal do

# Tests to make sure that:
# 1. Code is parsed into the correct tree
# 2. Tree evaluates to correct int32 result with both the Ruby and LibJIT
#    translators

coal_examples [

  "if(true) { return(1) }; return(0)",
  [[:if, true,
    [[:ret, 1]]],
  [:ret, 0]],
  1,
  
  # Single statement if block without braces
  "if(true) return(1); return(0)",
  [[:if, true,
    [[:ret, 1]]],
  [:ret, 0]],
  1,
  
  # Empty if
  "if(true) {}; return(1)",
  [[:if, true,
    []],
  [:ret, 1]],
  1,
  
  "if(false) { return(0) } else { return(1) } ; return(0)",
  [[:if, false,
    [[:ret, 0]
  ],[
    [:ret, 1]]],
  [:ret, 0]],
  1,
  
  "if(false) { return(0) } else if(true) { return(1) } ; return(0)",
  [[:if, false,
    [[:ret, 0]
  ],[
    [:if, true,
      [[:ret, 1]]]]],
  [:ret, 0]],
  1,
  
  "unless(false) { return(1) }; return(0)",
  [[:unless, false,
    [[:ret, 1]]],
  [:ret, 0]],
  1,
  
  # Single statement unless block without braces
  "unless(false) return(1); return(0)",
  [[:unless, false,
    [[:ret, 1]]],
  [:ret, 0]],
  1,
  
  # Empty unless
  "unless(false) {}; return(1)",
  [[:unless, false,
    []],
  [:ret, 1]],
  1,
  
  "unless(true) { return(0) } else { return(1) } ; return(0)",
  [[:unless, true,
    [[:ret, 0]
  ],[
    [:ret, 1]]],
  [:ret, 0]],
  1,
  
  "unless(true) { return(0) } else unless(false) { return(1) } ; return(0)",
  [[:unless, true,
    [[:ret, 0]
  ],[
    [:unless, false,
      [[:ret, 1]]]]],
  [:ret, 0]],
  1,
  
  # Mixed unless and if
  "unless(true) { return(0) } else if(true) { return(1) } ; return(0)",
  [[:unless, true,
    [[:ret, 0]
  ],[
    [:if, true, [[:ret, 1]]]]],
  [:ret, 0]],
  1,

]

end

