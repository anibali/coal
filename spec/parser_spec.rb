require File.dirname(__FILE__) + "/spec_helper"

describe Coal::Parser do
describe '.parse' do

subject { Coal::Parser.parse(@code) }

[
  '0xfff',                        [0xfff],
  '9',                            [9],
  '  54',                         [54],
  "0b1010\n",                     [0b1010],
  '2+4',                          [[:add, 2, 4]],
  '2 +4',                         [[:add, 2, 4]],
  '2+ 4',                         [[:add, 2, 4]],
  '2 + 4',                        [[:add, 2, 4]],
  '2    +    4',                  [[:add, 2, 4]],
  "2\t+\t4",                      [[:add, 2, 4]],
  "2\t + \t4",                    [[:add, 2, 4]],
  '2 + 4 * 3',                    [[:add, 2, [:mul, 4, 3]]],
  '2+4;7/9',                      [[:add, 2, 4], [:div, 7, 9]],
  '42 # The answer',              [42],
  ';;;;',                         [],
  "# Awesome\n# story\n# bro",    [],
].each_slice(2) do |code, tree|
  describe(code.inspect) do
    before { @code = code }
    it("should parse to #{tree.inspect}") { should eql(tree) }
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
  describe code.inspect do
    it do
      expect {
        Coal::Parser.new.parse(code)
      }.to raise_error(Coal::SyntaxError)
    end
  end
end

end ; end

