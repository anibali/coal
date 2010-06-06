require File.dirname(__FILE__) + "/spec_helper"

describe Coal do

# Tests to make sure that:
# 1. Code is parsed into the correct tree
# 2. Tree evaluates to correct int32 result with both the Ruby and LibJIT
#    translators

[

  "int8 i = 0 ; while(i < 10) { i += 1 }; return(i)",
  [[:decl, 'int8', 'i', 0],
  [:while, [:lt, 'i', 10],
    [[:sto, 'i', [:add, 'i', 1]]]],
  [:ret, 'i']],
  10,

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

end

