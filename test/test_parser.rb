require 'test/unit'

require 'coal'

class ParserTest < Test::Unit::TestCase
  def setup
    @parser = Coal::Parser.new
  end
  
  def test_function_call
    good "do_something()"
    good "do_something( )"
    
    good "sqrt(x)"
    bad  "sqrt x"
    
    good "add(x, y)"
    good "add(x,5)"
    bad  "add(x y)"
    
    good "f(x, 7, z)"
    bad  "f(x, 7 z)"
    
    good "f(g(x))"
    good "add(arg(x), arg(y))"
    good "add(arg(0), arg(1))"
  end
  
  def test_assignment
    good "foo=42"
    good "foo_bar=42"
    good "foo= 42"
    good "foo =42"
    good "foo = 42"
    good "foo = bar"
    bad  "foo = "
    bad  "= 42"
    bad  "42 = foo"
    bad  "foo = 42 bar"
    
    good "foo = sqrt(x)"
    good "x = add(arg(0), arg(1))"
    bad  "f(x) = x"
  end
  
  def test_declaration
    good "int32 foo"
    good "int32   foo"
    good "int32\tfoo"
    bad  "x int32"
  end
  
  def good exp
    tree = @parser.parse(exp)
    text_value = tree.text_value if tree
    assert_equal exp, text_value
  end
  
  def bad exp
    tree = @parser.parse(exp)
    text_value = tree.text_value if tree
    assert_equal nil, text_value
  end
end

