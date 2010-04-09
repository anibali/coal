require 'test/unit'

require 'coal'

class AssignmentTest < Test::Unit::TestCase
  def make_42 code
    tree = Coal::Parser.new.parse code
    
    [Coal::Translators::LibJIT, Coal::Translators::Ruby].each do |clazz|
      trans = clazz.new
      callable = trans.build_callable([], :int8, tree)
      res = callable.call
      assert_equal 42, res
    end
  end
  
  def test_bitwise_and
    make_42 <<-end
      return(106 & 63)
    end
  end
  
  def test_bitwise_xor
    make_42 <<-end
      return(21 ^ 63)
    end
  end
  
  def test_bitwise_or
    make_42 <<-end
      return(40 | 10)
    end
  end
end

