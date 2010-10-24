($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

exception = nil

begin
  Coal.module 'Hailstone' do
    function 'run', [:uint64], :uint64, <<-'end'
      uint64 n = arg(0)
      uint64 steps
      
      if(n % 2 == 0)
        steps = Hailstone.even(n, 0)
      else
        steps = Hailstone.odd(n, 0)
      
      return(steps)
    end
    
    function 'odd', [:uint64, :uint64], :uint64, <<-'end'
      uint64 n = arg(0)
      uint64 steps = arg(1)
      
      if(n > 1)
        steps = Hailstone.even(3 * n + 1, steps + 1)
      
      return(steps)
    end
    
    function 'even', [:uint64, :uint64], :uint64, <<-'end'
      uint64 n = arg(0)
      uint64 steps = arg(1)
      
      n /= 2
      
      if(n % 2 == 0)
        steps = Hailstone.even(n, steps + 1)
      else
        steps = Hailstone.odd(n, steps + 1)
      
      return(steps)
    end
  end
  
  describe Cl::Hailstone do
    describe ".run(113383)" do
      subject { Cl::Hailstone.run(113383) }
      it { should eql(247) }
    end
  end
rescue Exception => ex
  exception = ex
end

describe 'Cl::Hailstone' do
  it "should not raise an exception" do
    raise exception if exception
  end
end

