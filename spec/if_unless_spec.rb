require File.dirname(__FILE__) + "/spec_helper"

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
  
  "if(true) return(1); return(0)",
  [[:if, true,
    [[:ret, 1]]],
  [:ret, 0]],
  1,
  
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

]

describe "if(false) { return(0) } else if(true) { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(false) { return(1) }; return(0)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(false) return(1); return(0)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(false) {}; return(1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(true) { return(0) } else { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(true) { return(0) } else unless(false) { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(true) { return(0) } else if(true) { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

end

