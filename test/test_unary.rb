require 'test/unit'

require 'coal'

class UnaryTest < Test::Unit::TestCase
  def parse code
     code
  end
  
  def make_42 code
    tree = Coal::Parser.new.parse code
    
    [Coal::Translators::LibJIT, Coal::Translators::Ruby].each do |clazz|
      trans = clazz.new
      callable = trans.build_callable([], :int8, tree)
      res = callable.call
      assert_equal 42, res
    end
  end
  
  def test_negation
    make_42 <<-end
      int8 x = -42
      return(-x)
    end
  end
  
  def test_double_negation
    make_42 <<-end
      return(-(-(42)))
    end
  end
  
  def test_bitwise_not
    make_42 <<-end
      int8 x = 42
      x = ~x
      return(~x)
    end
  end
end

