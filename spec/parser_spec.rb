require File.dirname(__FILE__) + "/spec_helper"

describe Coal::Parser do

[
  "do_something()",
  "do_something( )",
  "sqrt(x)",
  "add(x, y)",
  "add(x,5)",
  "f(x, 7, z)",
  "f(g(x))",
  "add(arg(x), arg(y))",
  "add(arg(0), arg(1))",
  "foo = 42",
  "foo= 42",
  "foo =42",
  "foo\t=\t42",
  "foo = bar",
  "foo = sqrt(64)",
  "int32 foo",
  "int64\tbar",
  "uint8   \t baz"
].each do |code|
  describe "#parse(#{code.inspect})" do
    it do
      expect {
        Coal::Parser.new.parse(code)
      }.to_not raise_error(Coal::SyntaxError)
    end
  end
end

[
  "sqrt x",
  "add(1 5)",
  "foo(x, y z)",
  "f(x) = 5",
  "foo =",
  "= 31",
  "43 = foo",
  "foo = 42 bar",
  "x int32"
].each do |code|
  describe "#parse(#{code.inspect})" do
    it do
      expect {
        Coal::Parser.new.parse(code)
      }.to raise_error(Coal::SyntaxError)
    end
  end
end

end

