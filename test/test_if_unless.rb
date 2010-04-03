require 'test/unit'

require 'coal'

# Tests syntax for 'if' and 'unless' structures via varying implementations
# of an "over 9000" tester. Ruby code for the algorithm:
#  if arg > 9000
#    return true
#  else
#    return false
class HasCoalTest < Test::Unit::TestCase
  def parse code
     code
  end
  
  # Compile and run code, testing the results against Ruby implementation
  def over_9000 code
    tree = Coal::Parser.new.parse code
    
    [Coal::Translators::LibJIT, Coal::Translators::Ruby].each do |clazz|
      trans = clazz.new
      callable = trans.build_callable([:uint32], :uint8, tree)
      [-65, 8000, 9999, 9000, 1000000].each do |arg|
        res = callable.call(arg)
        if arg > 9000
          assert([true, 1].include? res)
        else
          assert([false, 0].include? res)
        end
      end
    end
  end
  
  def test_if
    over_9000 <<-end
      if(arg(0) > 9000)
      {
        return(true)
      }
      
      return(false)
    end
  end
  
  def test_empty_if
    over_9000 <<-end
      if(arg(0) > 9000)
      {
        return(true)
      }
      
      if(true)
      {
      }
      
      return(false)
    end
  end
  
  def test_if_without_braces
    over_9000 <<-end
      if(arg(0) > 9000)
        return(true)
      
      return(false)
    end
  end
  
  def test_if_else
    over_9000 <<-end
      if(arg(0) > 9000) {
        return(true)
      } else {
        return(false)
      }
      
      return(-1)
    end
  end
  
  def test_if_else_without_braces
    over_9000 <<-end
      if(arg(0) > 9000)
        return(true)
      else
        return(false)
      
      return(-1)
    end
  end
  
  def test_chained_if_else
    over_9000 <<-end
      if(arg(0) > 10000)
      {
        return(true)
      }
      else if(arg(0) > 9000)
      {
        return(true)
      }
      
      return(false)
    end
  end
  
  def test_unless
    over_9000 <<-end
      unless(arg(0) > 9000)
      {
        return(false)
      }
      
      return(true)
    end
  end
  
  def test_empty_unless
    over_9000 <<-end
      unless(arg(0) > 9000)
      {
        return(false)
      }
      
      unless(false)
      {
      }
      
      return(true)
    end
  end
  
  def test_unless_without_braces
    over_9000 <<-end
      unless(arg(0) > 9000)
        return(false)
      
      return(true)
    end
  end
  
  def test_unless_else
    over_9000 <<-end
      unless(arg(0) > 9000)
      {
        return(false)
      }
      else
      {
        return(true)
      }
      
      return(-1)
    end
  end
  
  def test_unless_else_without_braces
    over_9000 <<-end
      unless(arg(0) > 9000)
        return(false)
      else
        return(true)
      
      return(-1)
    end
  end
  
  def test_chained_unless_else
    over_9000 <<-end
      unless(arg(0) <= 10000)
      {
        return(true)
      }
      else unless(arg(0) <= 9000)
      {
        return(true)
      }
      
      return(false)
    end
  end
  
  def test_chained_unless_if_else
    over_9000 <<-end
      unless(arg(0) <= 10000)
      {
        return(true)
      }
      else if(arg(0) > 9000)
      {
        return(true)
      }
      
      return(false)
    end
  end
end

