require 'test/unit'

require 'coal'

class AssignmentTest < Test::Unit::TestCase
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
  
  def test_assign_sum
    make_42 <<-end
      int8 x = 40
      x += 2
      return(x)
    end
  end
  
  def test_assign_difference
    make_42 <<-end
      int8 x = 47
      x -= 5
      return(x)
    end
  end
  
  def test_assign_product
    make_42 <<-end
      int8 x = 6
      x *= 7
      return(x)
    end
  end
  
  def test_assign_product
    make_42 <<-end
      int8 x = 126
      x /= 3
      return(x)
    end
  end
  
  def test_assign_remainder
    make_42 <<-end
      int8 x = 85
      x %= 43
      return(x)
    end
  end
end

