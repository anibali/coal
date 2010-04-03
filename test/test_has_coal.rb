require 'test/unit'

require 'coal'

class HasCoalTest < Test::Unit::TestCase
  class Clas
    include Coal::HasCoal
    
    def_coal 'self.forty_two', [], :uint8, <<-end
      return(42)
    end
    
    def_coal 'twelve', [], :uint8, <<-end
      return(12)
    end
  end
  
  module Modul
    include Coal::HasCoal
    
    def_coal 'self.thirty_nine', [], :uint8, <<-end
      return(39)
    end
  end
  
  def test_module
    assert_equal 39, Modul.thirty_nine
  end
  
  def test_class
    assert_equal 42, Clas.forty_two
    assert_equal 12, Clas.new.twelve
  end
end

