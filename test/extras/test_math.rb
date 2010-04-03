require 'test/unit'

require 'coal'
require 'coal/extras/math'

class MathTest < Test::Unit::TestCase
  def test_fibonacci
    assert_equal 55, Coal::Math.fibonacci(10)
    assert_equal 4181, Coal::Math.fibonacci(19)
  end
  
  def test_factorial
    assert_equal 120, Coal::Math.factorial(5)
    assert_equal 3628800, Coal::Math.factorial(10)
  end
  
  def test_prime
    assert_equal 11, Coal::Math.prime(5)
    assert_equal 31, Coal::Math.prime(11)
  end
  
  def test_pow_of_2
    assert_equal 1, Coal::Math.pow_of_2(0)
    assert_equal 512, Coal::Math.pow_of_2(9)
    assert_equal 2048, Coal::Math.pow_of_2(11)
    assert_equal 1099511627776, Coal::Math.pow_of_2(40)
  end
end

