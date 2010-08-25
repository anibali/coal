$LOAD_PATH << File.join(File.dirname(File.expand_path(__FILE__)), '..', 'lib')
require 'coal'

def coal_examples(*args)
  array = args.last
  return_type = :int32
  return_type = args.first if args.length > 1
  array.each_slice(3) do |code, tree, result|
    describe "code \'#{code}\'" do
      it "should parse to #{tree.inspect}" do
        Coal::Parser.parse(code).should eql(tree)
      end
      
      it "should evaluate to #{result} with the Ruby translator" do
        trans = Coal::Translators::Ruby.new
        func = trans.compile_func(trans.declare_func([], return_type), tree)
        func.call().should eql(result)
      end
      
      it "should evaluate to #{result} with the LibJIT translator" do
        trans = Coal::Translators::LibJIT.new
        func = trans.compile_func(trans.declare_func([], return_type), tree)
        func.call().should eql(result)
      end
    end
  end
end

