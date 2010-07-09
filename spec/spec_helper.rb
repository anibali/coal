require File.dirname(__FILE__) + "/../lib/coal"

def coal_examples(array)
  array.each_slice(3) do |code, tree, result|
    describe "code \'#{code}\'" do
      it "should parse to #{tree.inspect}" do
        Coal::Parser.parse(code).should eql(tree)
      end
      
      it "should evaluate to #{result} with the Ruby translator" do
        trans = Coal::Translators::Ruby.new
        func = trans.compile_func(trans.declare_func([], :int32), tree)
        func.call().should eql(result)
      end
      
      it "should evaluate to #{result} with the LibJIT translator" do
        trans = Coal::Translators::LibJIT.new
        func = trans.compile_func(trans.declare_func([], :int32), tree)
        func.call().should eql(result)
      end
    end
  end
end

