require File.dirname(__FILE__) + "/spec_helper"

describe Coal do

# Tests to make sure that:
# 1. Code is parsed into the correct tree
# 2. Tree evaluates to correct int32 result with both the Ruby and LibJIT
#    translators

[

  "if(true) { return(1) }; return(0)",
  [[:if, true,
    [[:ret, 1]]],
  [:ret, 0]],
  1,

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

describe "if(true) return(1); return(0)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "if(true) {}; return(1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "if(false) { return(0) } else { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

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

