require File.dirname(__FILE__) + "/spec_helper"

describe Coal do

# Tests to make sure that:
# 1. Code is parsed into the correct tree
# 2. Tree evaluates to correct int32 result with both the Ruby and LibJIT
#    translators

[

  "int16 x = 42 ; return(x)",
  [[:decl, 'int16', 'x', 42], [:ret, 'x']],
  42,
                           
  "int8 x ; x = 2 ; return(x)",
  [[:decl, 'int8', 'x'], [:sto, 'x', 2], [:ret, 'x']],
  2,
  
  "int32 x = 7 ; x += 4 ; return(x)",
  [[:decl, 'int32', 'x', 7], [:sto, 'x', [:add, 'x', 4]], [:ret, 'x']],
  11,
  
  "int32 x = 12 ; x -= 3 ; return(x)",
  [[:decl, 'int32', 'x', 12], [:sto, 'x', [:sub, 'x', 3]], [:ret, 'x']],
  9,
  
  "int32 x = 7 ; x *= 2 ; return(x)",
  [[:decl, "int32", "x", 7], [:sto, "x", [:mul, "x", 2]], [:ret, "x"]],
  14,
  
  "int32 x = 42 ; x /= 6 ; return(x)",
  [[:decl, "int32", "x", 42], [:sto, "x", [:div, "x", 6]], [:ret, "x"]],
  7,
  
  "int32 x = 99 ; x %= 2 ; return(x)",
  [[:decl, "int32", "x", 99], [:sto, "x", [:mod, "x", 2]], [:ret, "x"]],
  1,
  
  "int32 x = 2 ; x **= 5 ; return(x)",
  [[:decl, "int32", "x", 2], [:sto, "x", [:pow, "x", 5]], [:ret, "x"]],
  32,

].each_slice(3) do |code, tree, result|
  describe "code \'#{code}\'" do
    it "should parse to #{tree.inspect}" do
      Coal::Parser.parse(code).should eql(tree)
    end
    
    it "should evaluate to #{result} with the Ruby translator" do
      func = Coal::Translators::Ruby.new.compile_func([], :int32, tree)
      func.call().should eql(result)
    end
    
    it "should evaluate to #{result} with the LibJIT translator" do
      func = Coal::Translators::LibJIT.new.compile_func([], :int32, tree)
      func.call().should eql(result)
    end
  end
end

describe "int32 x = 106 ; x &= 63 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x = 21 ; x ^= 63 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x = 40 ; x |= 10 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x = 21 ; x <<= 1 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x = 84 ; x >>= 1 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x ; return((x = 2) * 21)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x ; int32 y ; x = y = 13 ; return(x + y)" do
  it { should eval_with_libjit_to_int32(26) }
  it { should eval_with_ruby_to_int32(26) }
end

end

