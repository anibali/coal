require File.dirname(__FILE__) + "/../lib/coal"

def coal_examples(array)
  array.each_slice(3) do |code, tree, result|
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

