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
  
  def test_assign
    make_42 <<-end
      int8 x = 42
      return(x)
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
  
  def test_assign_quotient
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
  
  def test_assign_bitwise_and
    make_42 <<-end
      int8 x = 106
      x &= 63
      return(x)
    end
  end
  
  def test_assign_bitwise_xor
    make_42 <<-end
      int8 x = 21
      x ^= 63
      return(x)
    end
  end
  
  def test_assign_bitwise_or
    make_42 <<-end
      int8 x = 40
      x |= 10
      return(x)
    end
  end
  
  def test_assign_inline
    make_42 <<-end
      int8 x
      return((x = 2) * 21)
    end
  end
  
  def test_assign_multiple
    make_42 <<-end
      int8 x
      int8 y
      x = y = 21
      return(x + y)
    end
  end
end

